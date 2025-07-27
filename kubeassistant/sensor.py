from homeassistant.helpers.entity import Entity

async def async_setup_entry(hass, entry, async_add_entities):
    apis = hass.data["kubeassistant"]
    v1 = apis["v1"]
    apps_v1 = apis["apps_v1"]
    batch_v1 = apis["batch_v1"]
    networking_v1 = apis["networking_v1"]

    # Fetch all resources
    deployments = await hass.async_add_executor_job(apps_v1.list_deployment_for_all_namespaces)
    statefulsets = await hass.async_add_executor_job(apps_v1.list_stateful_set_for_all_namespaces)
    daemonsets = await hass.async_add_executor_job(apps_v1.list_daemon_set_for_all_namespaces)
    namespaces = await hass.async_add_executor_job(v1.list_namespace)
    nodes = await hass.async_add_executor_job(v1.list_node)
    cronjobs = await hass.async_add_executor_job(batch_v1.list_cron_job_for_all_namespaces)
    services = await hass.async_add_executor_job(v1.list_service_for_all_namespaces)
    ingresses = await hass.async_add_executor_job(networking_v1.list_ingress_for_all_namespaces)
    endpoints = await hass.async_add_executor_job(v1.list_endpoints_for_all_namespaces)
    secrets = await hass.async_add_executor_job(v1.list_secret_for_all_namespaces)
    configmaps = await hass.async_add_executor_job(v1.list_config_map_for_all_namespaces)

    sensors = []

    for dep in deployments.items:
        sensors.append(KubeDeploymentSensor(dep, apps_v1))
    for sts in statefulsets.items:
        sensors.append(KubeStatefulSetSensor(sts, apps_v1))
    for ds in daemonsets.items:
        sensors.append(KubeDaemonSetSensor(ds, apps_v1))
    for ns in namespaces.items:
        sensors.append(KubeNamespaceSensor(ns, v1))
    for node in nodes.items:
        sensors.append(KubeNodeSensor(node, v1))
    for cj in cronjobs.items:
        sensors.append(KubeCronJobSensor(cj, batch_v1))
    for svc in services.items:
        sensors.append(KubeServiceSensor(svc, v1))
    for ing in ingresses.items:
        sensors.append(KubeIngressSensor(ing, networking_v1))
    for ep in endpoints.items:
        sensors.append(KubeEndpointSensor(ep, v1))
    for sec in secrets.items:
        sensors.append(KubeSecretSensor(sec, v1))
    for cm in configmaps.items:
        sensors.append(KubeConfigMapSensor(cm, v1))

    async_add_entities(sensors)

# --- Sensor Classes ---

class KubeDeploymentSensor(Entity):
    def __init__(self, dep, api):
        self._dep = dep
        self._api = api

    @property
    def name(self):
        return f"K8s Deployment {self._dep.metadata.namespace}/{self._dep.metadata.name}"

    @property
    def unique_id(self):
        return f"k8s_deployment_{self._dep.metadata.uid}"

    @property
    def state(self):
        return self._dep.status.available_replicas or 0

    @property
    def extra_state_attributes(self):
        return {
            "namespace": self._dep.metadata.namespace,
            "replicas": self._dep.status.replicas,
            "updated_replicas": self._dep.status.updated_replicas,
            "unavailable_replicas": self._dep.status.unavailable_replicas,
        }

    async def async_update(self):
        dep = await self.hass.async_add_executor_job(
            self._api.read_namespaced_deployment,
            self._dep.metadata.name,
            self._dep.metadata.namespace,
        )
        self._dep = dep

class KubeStatefulSetSensor(Entity):
    def __init__(self, sts, api):
        self._sts = sts
        self._api = api

    @property
    def name(self):
        return f"K8s StatefulSet {self._sts.metadata.namespace}/{self._sts.metadata.name}"

    @property
    def unique_id(self):
        return f"k8s_statefulset_{self._sts.metadata.uid}"

    @property
    def state(self):
        return self._sts.status.ready_replicas or 0

    @property
    def extra_state_attributes(self):
        return {
            "namespace": self._sts.metadata.namespace,
            "replicas": self._sts.status.replicas,
            "ready_replicas": self._sts.status.ready_replicas,
            "current_replicas": self._sts.status.current_replicas,
            "updated_replicas": self._sts.status.updated_replicas,
        }

    async def async_update(self):
        sts = await self.hass.async_add_executor_job(
            self._api.read_namespaced_stateful_set,
            self._sts.metadata.name,
            self._sts.metadata.namespace,
        )
        self._sts = sts

class KubeNamespaceSensor(Entity):
    def __init__(self, ns, api):
        self._ns = ns
        self._api = api

    @property
    def name(self):
        return f"K8s Namespace {self._ns.metadata.name}"

    @property
    def unique_id(self):
        return f"k8s_namespace_{self._ns.metadata.uid}"

    @property
    def state(self):
        return self._ns.status.phase

    @property
    def extra_state_attributes(self):
        return {
            "labels": self._ns.metadata.labels,
            "creation_timestamp": str(self._ns.metadata.creation_timestamp),
            "status": self._ns.status.phase,
        }

    async def async_update(self):
        ns = await self.hass.async_add_executor_job(
            self._api.read_namespace,
            self._ns.metadata.name,
        )
        self._ns = ns

class KubeNodeSensor(Entity):
    def __init__(self, node, api):
        self._node = node
        self._api = api

    @property
    def name(self):
        return f"K8s Node {self._node.metadata.name}"

    @property
    def unique_id(self):
        return f"k8s_node_{self._node.metadata.uid}"

    @property
    def state(self):
        return "Ready" if any(
            c.type == "Ready" and c.status == "True" for c in self._node.status.conditions
        ) else "NotReady"

    @property
    def extra_state_attributes(self):
        return {
            "labels": self._node.metadata.labels,
            "addresses": [a.address for a in self._node.status.addresses],
            "capacity": self._node.status.capacity,
            "allocatable": self._node.status.allocatable,
            "conditions": [{ "type": c.type, "status": c.status } for c in self._node.status.conditions],
        }

    async def async_update(self):
        node = await self.hass.async_add_executor_job(
            self._api.read_node,
            self._node.metadata.name,
        )
        self._node = node

class KubeDaemonSetSensor(Entity):
    def __init__(self, ds, api):
        self._ds = ds
        self._api = api

    @property
    def name(self):
        return f"K8s DaemonSet {self._ds.metadata.namespace}/{self._ds.metadata.name}"

    @property
    def unique_id(self):
        return f"k8s_daemonset_{self._ds.metadata.uid}"

    @property
    def state(self):
        return self._ds.status.number_ready or 0

    @property
    def extra_state_attributes(self):
        return {
            "namespace": self._ds.metadata.namespace,
            "desired_number_scheduled": self._ds.status.desired_number_scheduled,
            "current_number_scheduled": self._ds.status.current_number_scheduled,
            "number_ready": self._ds.status.number_ready,
            "number_available": self._ds.status.number_available,
        }

    async def async_update(self):
        ds = await self.hass.async_add_executor_job(
            self._api.read_namespaced_daemon_set,
            self._ds.metadata.name,
            self._ds.metadata.namespace,
        )
        self._ds = ds

class KubeCronJobSensor(Entity):
    def __init__(self, cj, api):
        self._cj = cj
        self._api = api

    @property
    def name(self):
        return f"K8s CronJob {self._cj.metadata.namespace}/{self._cj.metadata.name}"

    @property
    def unique_id(self):
        return f"k8s_cronjob_{self._cj.metadata.uid}"

    @property
    def state(self):
        return self._cj.status.last_schedule_time or "Never"

    @property
    def extra_state_attributes(self):
        return {
            "namespace": self._cj.metadata.namespace,
            "schedule": self._cj.spec.schedule,
            "suspend": self._cj.spec.suspend,
            "active": [a.name for a in self._cj.status.active] if self._cj.status.active else [],
        }

    async def async_update(self):
        cj = await self.hass.async_add_executor_job(
            self._api.read_namespaced_cron_job,
            self._cj.metadata.name,
            self._cj.metadata.namespace,
        )
        self._cj = cj

class KubeServiceSensor(Entity):
    def __init__(self, svc, api):
        self._svc = svc
        self._api = api

    @property
    def name(self):
        return f"K8s Service {self._svc.metadata.namespace}/{self._svc.metadata.name}"

    @property
    def unique_id(self):
        return f"k8s_service_{self._svc.metadata.uid}"

    @property
    def state(self):
        return self._svc.spec.type

    @property
    def extra_state_attributes(self):
        return {
            "namespace": self._svc.metadata.namespace,
            "cluster_ip": self._svc.spec.cluster_ip,
            "ports": [p.to_dict() for p in self._svc.spec.ports],
            "selector": self._svc.spec.selector,
        }

    async def async_update(self):
        svc = await self.hass.async_add_executor_job(
            self._api.read_namespaced_service,
            self._svc.metadata.name,
            self._svc.metadata.namespace,
        )
        self._svc = svc

class KubeIngressSensor(Entity):
    def __init__(self, ing, api):
        self._ing = ing
        self._api = api

    @property
    def name(self):
        return f"K8s Ingress {self._ing.metadata.namespace}/{self._ing.metadata.name}"

    @property
    def unique_id(self):
        return f"k8s_ingress_{self._ing.metadata.uid}"

    @property
    def state(self):
        return self._ing.status.load_balancer.ingress[0].ip if self._ing.status.load_balancer and self._ing.status.load_balancer.ingress else "Pending"

    @property
    def extra_state_attributes(self):
        return {
            "namespace": self._ing.metadata.namespace,
            "rules": [r.to_dict() for r in self._ing.spec.rules],
            "tls": [t.to_dict() for t in self._ing.spec.tls] if self._ing.spec.tls else [],
        }

    async def async_update(self):
        ing = await self.hass.async_add_executor_job(
            self._api.read_namespaced_ingress,
            self._ing.metadata.name,
            self._ing.metadata.namespace,
        )
        self._ing = ing

class KubeEndpointSensor(Entity):
    def __init__(self, ep, api):
        self._ep = ep
        self._api = api

    @property
    def name(self):
        return f"K8s Endpoint {self._ep.metadata.namespace}/{self._ep.metadata.name}"

    @property
    def unique_id(self):
        return f"k8s_endpoint_{self._ep.metadata.uid}"

    @property
    def state(self):
        return len(self._ep.subsets[0].addresses) if self._ep.subsets and self._ep.subsets[0].addresses else 0

    @property
    def extra_state_attributes(self):
        return {
            "namespace": self._ep.metadata.namespace,
            "addresses": [a.ip for s in self._ep.subsets for a in getattr(s, "addresses", [])],
            "ports": [p.to_dict() for s in self._ep.subsets for p in getattr(s, "ports", [])],
        }

    async def async_update(self):
        ep = await self.hass.async_add_executor_job(
            self._api.read_namespaced_endpoints,
            self._ep.metadata.name,
            self._ep.metadata.namespace,
        )
        self._ep = ep

class KubeSecretSensor(Entity):
    def __init__(self, sec, api):
        self._sec = sec
        self._api = api

    @property
    def name(self):
        return f"K8s Secret {self._sec.metadata.namespace}/{self._sec.metadata.name}"

    @property
    def unique_id(self):
        return f"k8s_secret_{self._sec.metadata.uid}"

    @property
    def state(self):
        return len(self._sec.data) if self._sec.data else 0

    @property
    def extra_state_attributes(self):
        return {
            "namespace": self._sec.metadata.namespace,
            "type": self._sec.type,
            "data_keys": list(self._sec.data.keys()) if self._sec.data else [],
        }

    async def async_update(self):
        sec = await self.hass.async_add_executor_job(
            self._api.read_namespaced_secret,
            self._sec.metadata.name,
            self._sec.metadata.namespace,
        )
        self._sec = sec

class KubeConfigMapSensor(Entity):
    def __init__(self, cm, api):
        self._cm = cm
        self._api = api

    @property
    def name(self):
        return f"K8s ConfigMap {self._cm.metadata.namespace}/{self._cm.metadata.name}"

    @property
    def unique_id(self):
        return f"k8s_configmap_{self._cm.metadata.uid}"

    @property
    def state(self):
        return len(self._cm.data) if self._cm.data else 0

    @property
    def extra_state_attributes(self):
        return {
            "namespace": self._cm.metadata.namespace,
            "data_keys": list(self._cm.data.keys()) if self._cm.data else [],
        }

    async def async_update(self):
        cm = await self.hass.async_add_executor_job(
            self._api.read_namespaced_config_map,
            self._cm.metadata.name,
            self._cm.metadata.namespace,
        )
        self._cm = cm