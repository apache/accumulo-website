---
title: On Disk Encryption
category: security
order: 5
---

For an additional layer of security, Accumulo can encrypt files stored on-disk.  On Disk encryption was reworked
for 2.0, making it easier to configure and more secure.  Starting with 2.1, On Disk Encryption can now be configured
per table as well as for the entire instance (all tables). The files that can be encrypted include: [RFiles][design] and Write Ahead
Logs (WALs). NOTE: This feature is considered experimental and [upgrading](../administration/upgrading) a previously encrypted instance
is not supported. For more information, see the [notes below](#things-to-keep-in-mind).

## Configuration

To encrypt tables on-disk, encryption must be enabled before an Accumulo instance is initialized. This is
done by configuring a crypto service factory. If on-disk encryption is enabled on an existing cluster, only files
created after it is enabled will be encrypted and existing data won't be encrypted until compaction.

### Encrypting All Tables

To encrypt all tables, the generic crypto service factory can be used, `GenericCryptoServiceFactory`. This factory
is useful for general purpose on-disk encryption with no table context.
```
instance.crypto.opts.factory=org.apache.accumulo.core.spi.crypto.GenericCryptoServiceFactory
```

The `GenericCryptoServiceFactory` requires configuring a crypto service to load and this can be done by setting the
{% plink general.custom.crypto.service %} property.  The value of this property is the
class name of the service which will perform crypto on RFiles and WALs.
```
general.custom.crypto.service=org.apache.accumulo.core.spi.crypto.AESCryptoService
```

### Per Table Encryption

To encrypt per table, the per table crypto service factory can be used, `PerTableCryptoServiceFactory`. This factory
will load a crypto service configured by table.
```
instance.crypto.opts.factory=org.apache.accumulo.core.spi.crypto.PerTableCryptoServiceFactory
```

The `PerTableCryptoServiceFactory` requires configuring a crypto service to load for the table RFiles and this can be done by adding the
{% plink table.crypto.opts.service %} property to a table. Example in the accumulo shell:
```
createtable table1 -prop table.crypto.opts.service=org.apache.accumulo.core.spi.crypto.AESCryptoService
```
The `PerTableCryptoServiceFactory` also requires configuring a recovery and WAL crypto service by adding the following
properties to your `accumulo.properties` file.
```
general.custom.crypto.recovery.service=org.apache.accumulo.core.spi.crypto.AESCryptoService
general.custom.crypto.wal.service=org.apache.accumulo.core.spi.crypto.AESCryptoService
```

Out of the box, Accumulo provides the `AESCryptoService` for basic encryption needs.  This class provides AES encryption
with Galois/Counter Mode (GCM) for RFiles and Cipher Block Chaining (CBC) mode for WALs.  The additional property
below is required by this crypto service to be set using the {% plink general.custom.crypto.\* %} prefix.
```
general.custom.crypto.key.uri=file:///secure/path/to/crypto-key-file
```
This property tells the crypto service where to find the file containing the key encryption key. The key file can be 16 or 32 bytes.
For example, openssl can be used to create a random 32 byte key:
```
openssl rand -out /path/to/keyfile 32
```
Initializing Accumulo after these instance properties are set, will enable on-disk encryption across your entire cluster.

### Disabling Crypto

When using the AESCryptoService, crypto can be disabled by setting the property `general.custom.crypto.enabled` to false.
However, this will disable all crypto as there is currently no way to disable only for specific tables. When disabled
existing encrypted files can still be read and scanned as long as the Accumulo instance and any table specific
properties are still configured but new files will not be encrypted.

```
general.custom.crypto.enabled=false
```

## Custom Crypto

The new crypto interface for 2.0 allows for easier custom implementation of encryption and decryption. Your
class only has to implement the {% jlink org.apache.accumulo.core.spi.crypto.CryptoService %} interface to work with Accumulo.
The interface has 3 methods:
```java
  void init(Map<String,String> conf) throws CryptoException;
  FileEncrypter getFileEncrypter(CryptoEnvironment environment);
  FileDecrypter getFileDecrypter(CryptoEnvironment environment);
```
The `init` method is where you will initialize any resources required for crypto and will get called once per Tablet Server.
The `getFileEncrypter` method requires implementation of a {% jlink org.apache.accumulo.core.spi.crypto.FileEncrypter %}
for encryption and the `getFileDecrypter` method requires implementation of a {% jlink org.apache.accumulo.core.spi.crypto.FileDecrypter %}
for decryption. The `CryptoEnvironment` passed into these methods will provide the scope of the crypto.
The FileEncrypter has two methods:
```java
  OutputStream encryptStream(OutputStream outputStream) throws CryptoService.CryptoException;
  byte[] getDecryptionParameters();
```
The `encryptStream` method performs the encryption on the provided OutputStream and returns an OutputStream, most likely
wrapped in at least one other OutputStream.  The `getDecryptionParameters` returns a byte array of anything that will be
required to perform decryption. The FileDecrypter only has one method:
```java
  InputStream decryptStream(InputStream inputStream) throws CryptoService.CryptoException;
```
For more help getting started see {% jlink org.apache.accumulo.core.security.crypto.impl.AESCryptoService %}.

## Things to keep in mind

### Utilities need access to encryption properties

When utilities run that read encrypted files but do not connect to Zookeeper the utility needs to be provided
the encryption properties. For example, when using [rfile-info](../troubleshooting/tools#rfileinfo) to examine
an encrypted rfile the accumulo.properties file can be copied, the necessary encryption parameters added,
and then the properties file can be passed to the utility with the `-p` argument.

### Some data will be unencrypted

The on-disk encryption configured here is only for RFiles and Write Ahead Logs (WALs).  The majority of data in Accumulo
is written to disk with these files, but there are a few scenarios that can take place where data will be unencrypted,
even with the crypto service enabled.

#### Data in Memory & Logs

For queries, data is decrypted when read from RFiles and cached in memory.  This means that data is unencrypted in memory
while Accumulo is running.  Depending on the situation, this also means that some data can be printed to logs. A stacktrace being logged
during an exception is one example. Accumulo developers have made sure not to expose data protected by authorizations during logging, but
it's the additional data that gets encrypted on-disk that could be exposed in a log file.

#### Bulk Import

There are 2 ways to create RFiles for bulk ingest: with the [RFile API][rfile] and during Map Reduce using [AccumuloFileOutputFormat].
The [RFile API][rfile] allows passing in the configuration properties for encryption mentioned above.  The [AccumuloFileOutputFormat] does
not allow for encryption of RFiles so any data bulk imported through this process will be unencrypted.

#### Zookeeper

Accumulo stores a lot of metadata about the cluster in Zookeeper.  Keep in mind that this metadata does not get encrypted with On Disk encryption enabled.

## GCM performance

The AESCryptoService uses GCM mode for RFiles. [Java 9 introduced GHASH hardware support used by GCM.](https://openjdk.java.net/jeps/246)

A test was performed on a VM with 4 2.3GHz processors and 16GB of RAM. The test encrypted and decrypted arrays of size 131072 bytes 1000000 times. The results are as follows:

    Java 9 GCM times:
        Time spent encrypting:        209.210s
        Time spent decrypting:        276.800s
    Java 8 GCM times:
        Time spent encrypting:        2,818.440s
        Time spent decrypting:        2,883.960s

As you can see, there is a significant performance hit when running without the GHASH CPU instruction. It is advised Java 9 or later be used when enabling encryption.

[Kerberos]: {% durl security/kerberos %}
[design]: {% durl getting-started/design#rfile %}
[rfile]: {% jurl org.apache.accumulo.core.client.rfile.RFile %}
[AccumuloFileOutputFormat]: {% jurl org.apache.accumulo.hadoop.mapreduce.AccumuloFileOutputFormat %}
