---
title: On Disk Encryption
category: administration
order: 14
---

For an additional layer of security, Accumulo can encrypt files stored on disk.  On Disk encryption was reworked 
for 2.0, making it easier to configure and more secure.  The files that can be encrypted include: [RFiles][design] and Write Ahead Logs (WALs).

## Configuration

To encrypt all tables on disk, encryption must be enabled before an Accumulo instance is initialized.  If on disk 
encryption is enabled on an existing cluster, only files created after it is enabled will be encrypted 
(root and metadata tables will not be encrypted in this case) and existing data won't be encrypted until compaction.  To configure on disk encryption, add the 
{% plink instance.crypto.service %} property to your `accumulo.properties` file.  The value of this property is the
class name of the service which will perform crypto on RFiles and WALs. 
```
instance.crypto.service=org.apache.accumulo.core.security.crypto.impl.AESCryptoService
```
Out of the box, Accumulo provides the `AESCryptoService` for basic encryption needs.  This class provides AES encryption 
with Galois/Counter Mode (GCM) for RFiles and Cipher Block Chaining (CBC) mode for WALs.  The additional properties 
below are required by this crypto service to be set using the {% plink instance.crypto.opts.* %} prefix.
```
instance.crypto.opts.key.provider=uri
instance.crypto.opts.key.location=file:///secure/path/to/crypto-key-file
```
The first property tells the crypto service how it will get the key encryption key.  The second property tells the service 
where to find the key.  For now, the only valid values are "uri" and the path to the key file. The key file can be 16 or 32 bytes. 
Initializing Accumulo after these instance properties are set, will enable on disk encryption across your entire cluster.

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

The on disk encryption configured here is only for R-files and Write Ahead Logs (WALs).  The majority of data in Accumulo 
is written to disk with these files but there are a few scenarios that can take place where data will be unencrypted, 
even with the crypto service enabled.

### Sorted WALs

If a tablet server is killed with WALs enabled, Accumulo will create temporary sorted WALs during recovery that are unencrypted.  
These files will only contain recent data that has not been compacted but will be written to the disk unencrypted. Once recovery 
is finished, these unencrypted files will be removed.

### Data in Memory & Logs

For queries, data is decrypted when read from RFiles and cached in memory.  This means that data is unencrypted in memory 
while Accumulo is running.  Depending on the situation, this also means that some data can be printed to logs. A stacktrace being logged 
during an exception is one example. Accumulo developers have made sure not to expose data protected by authorizations during logging but 
its the additional data that gets encrypted on disk that could be exposed in a log file. 

### Bulk Import

There are 2 ways to create RFiles for bulk ingest: with the [RFile API][rfile] and during Map Reduce using [AccumuloOutputFormat].  
The [RFile API][rfile] allows passing in the configuration properties for encryption mentioned above.  The [AccumuloOutputFormat] does 
not allow for encryption of RFiles so any data bulk imported through this process will be unencrypted.

### Zookeeper

Accumulo stores a lot of metadata about the cluster in Zookeeper.  Keep in mind that this metadata does not get encrypted with On Disk encryption enabled.

[design]: {{ page.docs_baseurl }}/getting-started/design#rfile
[rfile]: {% jurl org.apache.accumulo.core.client.rfile.RFile %}
[AccumuloOutputFormat]: {% jurl org.apache.accumulo.core.client.mapred.AccumuloOutputFormat %}