module "podtatohead-1" {
  source = "./modules/podtatohead"
  podtato_name = "first"
  hats_version = "v3"
  left_arm_version = "v2"
  left_leg_version = "v1"
  podtato_version = "v0.1.0"
  right_arm_version = "v4"
  right_leg_version = "v1"
  VarDdApiKey = "<VarDdApiKey>"
  VarDdImage = "gcr.io/datadoghq/agent:7"
  gitHubUser = "<gitHubUser>"
  gitHubClientId = "<gitHubClientI>"
  gitHubClientSecret = "<gitHubClientSecret>"
}


output "first-url" {
  value = module.podtatohead-1.podtato-url
}