# Build 310 image
docker image remove realworldhealth/py310:latest
docker build -t realworldhealth/py310:latest -f py310.dockerfile .
docker push realworldhealth/py310:latest

# Build 310-lite image
docker image remove realworldhealth/py310-lite:latest
docker build -t realworldhealth/py310-lite:latest -f py310-lite.Dockerfile .
docker push realworldhealth/py310-lite:latest

# Build 39-lite image
docker image remove realworldhealth/py39-lite:latest
docker build -t realworldhealth/py39-lite:latest -f py39-lite.Dockerfile .
docker push realworldhealth/py39-lite:latest

#Test run locally
$image = "py310-lite:latest"
$instance = "xxx"
$notebook_path = "xxx"
$output_path = "xxx"
$azure_client_id = "xxx"
$azure_client_secret = "xxx
$azure_tenant_id = "xxx"

docker run --rm `
  -v /Volumes/"$instance":/mnt/"$instance" `
  -e NOTEBOOK_PATH=$notebook_path `
  -e OUTPUT_PATH=$output_path `
  -e AZURE_CLIENT_ID=$azure_client_id `
  -e AZURE_CLIENT_SECRET=$azure_client_secret `
  -e AZURE_TENANT_ID=$azure_tenant_id `
  realworldhealth/"$image"

#Test run in ACI
$image = "py310-lite:latest"
$fs_account_name = "xxx"
$fs_account_key = "xxx"
$instance = "xxx"
$notebook_path = "xxx"
$output_path = "xxx"
$azure_client_id = "xxx"
$azure_client_secret = "xxx"
$azure_tenant_id = "xxx"
$guid = [guid]::NewGuid().ToString()

# Use the generated GUID in your container name
az container create `
  --resource-group dsp-containers `
  --name "dsp-${guid}" `
  --image "realworldhealth/$image" `
  --protocol tcp `
  --cpu 1 `
  --memory 1 `
  --azure-file-volume-account-name $fs_account_name `
  --azure-file-volume-account-key $fs_account_key `
  --azure-file-volume-share-name $instance `
  --azure-file-volume-mount-path "/mnt/$instance" `
  --environment-variables NOTEBOOK_PATH=$notebook_path OUTPUT_PATH=$output_path AZURE_CLIENT_ID=$azure_client_id  AZURE_CLIENT_SECRET=$azure_client_secret AZURE_TENANT_ID=$azure_tenant_id `
  --restart-policy Never `
  --vnet dsp-container-vnet `
  --subnet dspcontainer-subnet

az container logs --resource-group dsp-containers --name "dsp-${guid}"
az container delete --name "dsp-${guid}" --resource-group dsp-containers --yes
