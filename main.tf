resource "azurerm_resource_group" "main" {
  name     = "${var.name}-rg"
  location = var.region
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.name}-vnet"
  address_space       = ["10.0.0.0/12"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {
  name                 = "main-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.0/16"]
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = "${var.name}-aks"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "${var.name}-aks"

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = "Standard_D2s_v4"
    vnet_subnet_id = azurerm_subnet.main.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "kubenet"

    pod_cidr       = "10.1.0.0/16"
    service_cidr   = "10.2.0.0/16"
    dns_service_ip = "10.2.0.10"
  }

  tags = {
    Environment = "PoC"
  }
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.main.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive = true
}
