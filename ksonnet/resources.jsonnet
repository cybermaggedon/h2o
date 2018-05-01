
//
// Definition for H2O on Kubernetes.  This creates an H2O cluster.
//

// Import KSonnet library.
local k = import "ksonnet.beta.2/k.libsonnet";

// Short-cuts to various objects in the KSonnet library.
local depl = k.extensions.v1beta1.deployment;
local container = depl.mixin.spec.template.spec.containersType;
local containerPort = container.portsType;
local mount = container.volumeMountsType;
local volume = depl.mixin.spec.template.spec.volumesType;
local resources = container.resourcesType;
local env = container.envType;
local gceDisk = volume.mixin.gcePersistentDisk;
local svc = k.core.v1.service;
local svcPort = svc.mixin.spec.portsType;
local svcLabels = svc.mixin.metadata.labels;

local h2o(config) = {

    name:: "h2o",
    version:: import "version.jsonnet",
    images:: ["docker.io/cybermaggedon/h2o:" + self.version],

    replicas:: 3,

    nodes:: std.join(",", std.makeArray(count, function(x) "h2o-%03d.h2o" % x)),

    // Ports used by master/main name node.
    ports:: [
        containerPort.newNamed("http", 54321)
    ],

    // Environment variables
    envs:: [
	// Set memory
        env.new("H2O_MEMORY", "1g"),
        env.new("H2O_NODES", self.nodes)
    ],

    // Container definition.
    containers:: [
        container.new(self.name, self.images[0]) +
            container.ports(self.ports) +
            container.env(self.envs) +
            container.mixin.resources.limits({
                memory: "1.2G", cpu: "1"
            }) +
            container.mixin.resources.requests({
                memory: "1.2G", cpu: "0.5"
            })
    ],

    // Stateful set
    statefulSets:: [
	local spec = sSet.mixin.spec;
	sSet.new() +
	    sSet.mixin.metadata.name("h2o") +
	    spec.template.metadata.labels({app: "h2o",
					   component: "ml"}) +
	    spec.replicas(self.replicas) +
	    spec.updateStrategy.type("RollingUpdate") +
	    spec.serviceName("h2o") +
	    spec.template.spec.containers(self.containers) +
	    { spec+: { podManagementPolicy: "Parallel" }}
    ],

    // Ports declared on the service.
    svcPorts:: [
        svcPort.newNamed("http", 54321, 54321) + svcPort.protocol("TCP")
    ],

    services:: [
        svc.new("h2o", {app: "h2o"}, self.svcPorts) +
            svcLabels({app: "h2o", component: "ml"})
    ],

    resources:
	self.statefulSets + self.services

};

// Return the function which creates resources.
h2o

