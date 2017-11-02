package tour;


import org.apache.accumulo.minicluster.MiniAccumuloCluster;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

public class Main {

    public static void main(String[] args) throws Exception {
        System.out.println("Running the Accumulo tour. Having fun yet?");

        Path tempDir = Files.createTempDirectory(Paths.get("target"), "mac");
        MiniAccumuloCluster mac = new MiniAccumuloCluster(tempDir.toFile(), "tourguide");

        mac.start();
        exercise(mac);
        mac.stop();
    }

    static void exercise(MiniAccumuloCluster mac) {
        // start writing your code here
    }
}
