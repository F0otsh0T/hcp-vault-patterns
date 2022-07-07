---


---

---

# 








## 









## 

#### KV2 Secrets Engine

KV2 Secrets Engine enabled and populated in this step will be retrieved via **Persona**: ```app``` later with access ```token``` harvested from **AppRole** ```auth```.

```shell
vault secrets enable -version=2 -path=nginx kv
Success! Enabled the kv secrets engine at: secret/data/nginx/

vault kv put -format=json nginx/secret foo=bar | jq
{
  "request_id": "7e98faad-4e5e-fca9-d799-11750ba1bf5a",
  "lease_id": "",
  "lease_duration": 0,
  "renewable": false,
  "data": {
    "created_time": "2022-06-21T06:05:13.036303634Z",
    "custom_metadata": null,
    "deletion_time": "",
    "destroyed": false,
    "version": 1
  },
  "warnings": null
}

vault kv get -format=json  nginx/secret | jq
{
  "request_id": "275fdc50-5c3a-74c2-f0d5-6add3cf2a4e5",
  "lease_id": "",
  "lease_duration": 0,
  "renewable": false,
  "data": {
    "data": {
      "foo": "bar"
    },
    "metadata": {
      "created_time": "2022-06-21T06:05:13.036303634Z",
      "custom_metadata": null,
      "deletion_time": "",
      "destroyed": false,
      "version": 2
    }
  },
  "warnings": null
}

```
