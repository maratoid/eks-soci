package buildkit


#BaseName: string | *"buildkit" @tag(name)
#Namespace: string | *"default" @tag(namespace)
#Replicas: int & >=0 | *2 @tag(replicas)
#QemuImage: string | *"tonistiigi/binfmt:qemu-v8.1.5" @tag(qemuimg)
#BuildkitImage: string | *"ghcr.io/maratoid/containerd-soci-builder:0.18.1" @tag(buldkitimg)
#ScaleRetentionPolicy: *"Retain" | "Delete" @tag(scalepol)
#DeleteRetentionPolicy: *"Retain" | "Delete" @tag(deletepol)
#StorageSize: string | *"10Gi" @tag(storagesize)
#StorageMode: string | [string] | *["ReadWriteOnce"] @tag(storagemode)
#Labels: [string]: string | *{}
#Annotations: [string]: string | *{}

_values: {
	suffix: {
		statefulset: "ss"
		service: "svc"
		serviceaccount: "sa"
		configmap: "cm"
		certificate: "cert"
		issuer: "iss"
		secret: "tls"
	}

	components: [Type=_]: {
		metadata: name: "\(#BaseName)-\(suffix["\(Type)"])"
		metadata: namespace: #Namespace
		metadata: annotations: #Annotations
		metadata: labels: #Labels & { "app.kubernetes.io/name": #BaseName }
		...
	}
}

_values: {
	components: {
		statefulset: {
			spec: replicas: #Replicas
			spec: persistentVolumeClaimRetentionPolicy: whenDeleted: #DeleteRetentionPolicy
        	spec: persistentVolumeClaimRetentionPolicy: whenScaled: #ScaleRetentionPolicy
			spec: volumeClaimTemplates: [
				{
					spec: accessModes: #StorageMode
					spec: resources: requests: storage: #StorageSize
				}
			]

			spec: template: metadata: annotations: [string]: string | *{}
			spec: template: metadata: labels: [string]: string | *{}
			spec: template: spec: initContainers: [ 
				{ 
					image: #QemuImage
					resources: requests: memory: "128Mi"
					resources: requests: cpu: "500m"
					resources: limits: memory: "128Mi" 
				} 
			]
			spec: template: spec: containers: [ 
				{ 
					image: #BuildkitImage
					resources: requests: memory: "3G"
					resources: requests: cpu: "1"
					resources: limits: memory: "3G"
				} 
			]
		}
		serviceaccount: {}
		service: {}
		configmap: {}
		certificate: {}
		issuer: {}
	}
}



