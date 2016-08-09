#
# Cookbook Name:: build-cookbook
# Recipe:: deploy
#
# Copyright (c) 2016 The Authors, All Rights Reserved.


if demo_delivery_stage == 'delivered'
  #########################################################################
  # PUSH TO GITHUB
  #########################################################################
  delivery_bus_secrets = get_project_secrets

  delivery_github 'Push knife-azure to demo_branch on GitHub' do
    repo_path delivery_workspace_repo
    cache_path delivery_workspace_cache
    branch demo_delivery_pipeline
    deploy_key delivery_bus_secrets['github_private_key']
    remote_name node['knife_azure']['remote_name']
    remote_url node['knife_azure']['remote_url']

    action :push
  end
end