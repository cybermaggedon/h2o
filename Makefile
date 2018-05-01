

# Need to train with the same version we run in the container.
H2O_VERSION=3.18.0.8

VERSION=${H2O_VERSION}
H2O=h2o-${H2O_VERSION}.zip

all: container

container: ${H2O}
	docker build \
	  --build-arg VERSION=${H2O_VERSION} \
	  -t docker.io/cybermaggedon/h2o:${VERSION} \
	  -f Dockerfile .

version: FORCE
	@echo ${VERSION}

FORCE:

push:
	gcloud docker -- push \
	  docker.io/cybermaggedon/h2o:${VERSION}

URL=http://h2o-release.s3.amazonaws.com/h2o/rel-wolpert/8/h2o-${H2O_VERSION}.zip

${H2O}:
	wget -O$@ ${URL}

run:
	docker run -i -t docker.io/cybermaggedon/h2o:${VERSION}

cluster:
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


