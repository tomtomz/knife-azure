#
# Cookbook Name:: build_cookbook
# Recipe:: deploy
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

gem_build_path = "#{node['delivery']['workspace']['repo']}".gsub("acceptance/deploy", "build/publish")
secrets = get_project_secrets

=begin
file '/tmp/azure-credentials.publishsettings' do
  action :delete
  only_if { File.exist? '/tmp/azure-credentials.publishsettings' }
end

file '/tmp/knife.rb' do
  action :delete
  only_if { File.exist? '/tmp/knife.rb' }
end

template "/tmp/azure-credentials.publishsettings" do
  source "azure_credentials.erb"
  mode '0777'
  variables ({
    :azure_publish_settings => secrets['azure_publish_settings']
  })
end

template "/tmp/knife.rb" do
  source "knife.erb"
  mode '0777'
  variables ({
    :azure_subscription_id => secrets['azure_subscription_id'],
    :azure_tenant_id => secrets['azure_tenant_id'],
    :azure_client_id => secrets['azure_client_id'],
    :azure_client_secret => secrets['azure_client_secret']
  })
end

template '/tmp/client.pem' do
  source "client.erb"
  mode '0777'
  variables ({
    :key => secrets['key']
  })
end

execute "gem_install_knife_azure" do
  cwd "#{gem_build_path}"
  command "gem install knife-azure-*.gem "
  notifies :run, 'execute[knife_azure_server_create]', :immediately
end

execute "knife_azure_server_create" do
  cwd "#{node['delivery']['workspace']['repo']}"
  command "knife azure server create --azure-vm-name #{node['delivery']['azure']['linux_vmname']} --node-name #{node['delivery']['azure']['linux_vmname']} --azure-source-image 0b11de9248dd4d87b18621318e037d37__RightImage-Ubuntu-14.04-x64-v14.1.5.1 --bootstrap-protocol cloud-api --azure-service-location 'West US' --ssh-user azure --ssh-password azure@123 --azure-publish-settings-file /tmp/azure-credentials.publishsettings -c /tmp/knife.rb -VV"
  action :nothing
  notifies :run, 'execute[knife_azure_server_delete]', :immediately
end

execute "knife_azure_server_delete" do
  cwd "#{node['delivery']['workspace']['repo']}"
  command "knife azure server delete #{node['delivery']['azure']['linux_vmname']} --node-name #{node['delivery']['azure']['linux_vmname']} --azure-publish-settings-file /tmp/azure-credentials.publishsettings --purge -c /tmp/knife.rb -y -VV"
  action :nothing
  notifies :run, 'execute[knife_azurerm_server_create]', :immediately
end

execute "knife_azurerm_server_create" do
  cwd "#{node['delivery']['workspace']['repo']}"
  command "knife azurerm server create --azure-resource-group-name pipeline-rgp --azure-storage-account linuxvm --azure-vm-name #{node['delivery']['azurerm']['linux_vmname']} --node-name #{node['delivery']['azurerm']['linux_vmname']} --azure-service-location westus --azure-image-os-type ubuntu -x azure -P azure@123 -c /tmp/knife.rb -VV"
  action :nothing
  notifies :run, 'execute[knife_azure_server_create_windows]', :immediately
end

execute "knife_azure_server_create_windows" do
  cwd "#{node['delivery']['workspace']['repo']}"
  command "knife azure server create --azure-vm-name #{node['delivery']['azure']['windows_vmname']} --node-name #{node['delivery']['azure']['windows_vmname']} --azure-source-image bd507d3a70934695bc2128e3e5a255ba__RightImage-Windows-2012R2-x64-v14.2 --bootstrap-protocol cloud-api --azure-service-location 'West US' -x azure -P azure@123 --azure-publish-settings-file /tmp/azure-credentials.publishsettings -c /tmp/knife.rb -VV"
  action :nothing
  notifies :run, 'execute[knife_azurerm_server_create_windows]', :immediately
end

execute "knife_azurerm_server_create_windows" do
  cwd "#{node['delivery']['workspace']['repo']}"
  command "knife azurerm server create --azure-resource-group-name pipeline-rgp --azure-storage-account winvm --azure-vm-name #{node['delivery']['azurerm']['windows_vmname']} --node-name #{node['delivery']['azurerm']['windows_vmname']} --azure-service-location westus --azure-image-os-type windows -x azure -P azure@123 -c /tmp/knife.rb -VV"
  action :nothing
  notifies :run, 'execute[knife_azure_server_delete_windows]', :immediately
end

execute "knife_azure_server_delete_windows" do
  cwd "#{node['delivery']['workspace']['repo']}"
  command "knife azure server delete #{node['delivery']['azure']['windows_vmname']} --node-name #{node['delivery']['azure']['windows_vmname']} --azure-publish-settings-file /tmp/azure-credentials.publishsettings --purge -c /tmp/knife.rb -y -VV"
  action :nothing
  notifies :run, 'execute[knife_azurerm_server_delete]', :immediately
end

execute "knife_azurerm_server_delete" do
  cwd "#{node['delivery']['workspace']['repo']}"
  command "knife azurerm server delete #{node['delivery']['azurerm']['linux_vmname']} --azure-resource-group-name pipeline-rgp --node-name #{node['delivery']['azurerm']['linux_vmname']} --delete-resource-group --purge -y -c /tmp/knife.rb -VV"
  action :nothing
  notifies :run, 'execute[knife_azurerm_server_delete_windows]', :immediately
end

execute "knife_azurerm_server_delete_windows" do
  cwd "#{node['delivery']['workspace']['repo']}"
  command "knife azurerm server delete #{node['delivery']['azurerm']['windows_vmname']} --azure-resource-group-name pipeline-rgp --node-name #{node['delivery']['azurerm']['windows_vmname']} --delete-resource-group --purge -y -c /tmp/knife.rb -VV"
  action :nothing
end
=end

if delivery_stage == 'delivered'
  #########################################################################
  # PUSH TO GITHUB
  #########################################################################
  delivery_bus_secrets = DeliverySugar::ChefServer.new.encrypted_data_bag_item('delivery-bus', 'secrets')

  delivery_github 'Push knife-azure to demo_branch on GitHub' do
    repo_path delivery_workspace_repo
    cache_path delivery_workspace_cache
    branch delivery_pipeline
    deploy_key delivery_bus_secrets['github_private_key']
    remote_name node['knife_azure']['remote_name']
    remote_url node['knife_azure']['remote_url']

    action :push
  end
end
