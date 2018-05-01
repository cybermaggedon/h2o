
H2O clusterable docker container.

Single-node usage:

   docker run -d -p 54321:54321 docker.io/cybermaggedon/h2o:${VERSION}

Cluster usage:

   docker run \
     --name=n1 \
     -p 54321:54321 \
     -e H2O_MEMORY=256m \
     -e H2O_NODES=n1:54321,n2:54321,n3:54321 \
     -d docker.io/cybermaggedon/h2o:${VERSION}
   docker run \
     --name=n2 \
     --link n1:n1 \
     -e H2O_MEMORY=256m \
     -e H2O_NODES=n1:54321,n2:54321,n3:54321 \
     -d docker.io/cybermaggedon/h2o:${VERSION}
   docker run \
     --name=n3 \
     --link n1:n1 \
     --link n2:n2 \
     -e H2O_MEMORY=256m \
     -e H2O_NODES=n1:54321,n2:54321,n3:54321 \
     -d docker.io/cybermaggedon/h2o:${VERSION}

Environment variables:

- H2O_MEMORY, memory spec used for a Java -Xmx parameter.
- H2O_NODES, list of cluster nodes, comma-separate host:port list.

