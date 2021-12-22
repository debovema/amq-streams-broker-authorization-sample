kubens default
kubectl delete ns openldap

kubectl create ns openldap
kubens openldap

helm install openldap-server -f openldap/values.yaml openldap/chart

kubectl wait --for=condition=Ready  --timeout=360s pod/openldap-server-0

sleep 20

openldap_pod=$(kubectl get po -l app=openldap-server -o custom-columns=:metadata.name)
openldap_pod=`echo $openldap_pod | xargs`

echo $openldap_pod

# copy files to openldap pod
kubectl cp openldap/00-ou.ldif $openldap_pod:/root
kubectl cp openldap/01-groups.ldif $openldap_pod:/root
kubectl cp openldap/02-users.ldif $openldap_pod:/root
kubectl cp openldap/add-pepe-to-read.ldif $openldap_pod:/root
kubectl cp openldap/remove-pepe-from-read.ldif $openldap_pod:/root

# import ldif entries
kubectl exec -it $openldap_pod -- /bin/bash -c 'ldapadd -x -H ldap://openldap-server.openldap:389 -D "cn=admin,dc=example,dc=org" -w admin -f ~/00-ou.ldif'
kubectl exec -it $openldap_pod -- /bin/bash -c 'ldapadd -x -H ldap://openldap-server.openldap:389 -D "cn=admin,dc=example,dc=org" -w admin -f ~/01-groups.ldif'
kubectl exec -it $openldap_pod -- /bin/bash -c 'ldapadd -x -H ldap://openldap-server.openldap:389 -D "cn=admin,dc=example,dc=org" -w admin -f ~/02-users.ldif'
kubectl exec -it $openldap_pod -- /bin/bash -c 'ldapsearch -x -H ldap://openldap-server.openldap:389 -b dc=example,dc=org -D "cn=admin,dc=example,dc=org" -w admin'

