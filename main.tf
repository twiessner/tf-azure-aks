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

  dns_prefix              = "${var.name}-aks"
  private_cluster_enabled = false

  default_node_pool {
    name     = "system"
    vm_size  = "Standard_A2m_v2"
    zones    = ["1"]
    max_pods = 250

    os_sku         = "Ubuntu"
    vnet_subnet_id = azurerm_subnet.main.id

    enable_auto_scaling = true
    node_count          = 1
    min_count           = 1
    max_count           = 1

    os_disk_size_gb = 100
    only_critical_addons_enabled = false
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"

    pod_cidr       = "10.1.0.0/16"
    service_cidr   = "10.2.0.0/16"
    dns_service_ip = "10.2.0.10"
  }

  tags = {
    Environment = "PoC"
  }
}
