#-------------------------------------------------------------------------
# Copyright (c) Microsoft. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#--------------------------------------------------------------------------
require "singleton"

module Azure

  # Proxy config method.
  def self.config
    Core.config
  end

  # Proxy configure method.
  def self.configure
    yield Core.config
  end

  module Core

    # Public: Sugar to configure the services in a neatly wrapped DSL.
    #
    # Yields the Azure::Configuration instance.
    #
    # Example:
    #
    #   Azure.configure do |config|
    #     config.storage_account_name = ENV["AZURE_STORAGE_ACCOUNT"]
    #   end
    #
    # Returns nothing.
    def self.configure
      yield config
    end

    # Public: Access the service configuration.
    #
    # Returns the Azure::Configuration instance.
    def self.config
      Configuration.instance
    end

    # Singleton that keeps the configuration of the system.
    class Configuration
      include Singleton

      # Public: Get/Set the Access Key for this service.
      attr_accessor :storage_access_key

      # Public: Get/Set the Account Name for this service.
      attr_accessor :storage_account_name

      # Public: Get/Set the Service Bus Access Key (Issuer Secret) for this service.
      attr_accessor :sb_access_key

      # Public: Set the Service Bus Issuer for this service.
      attr_writer :sb_issuer

      # Public: Get the issuer for the service bus. If you set something using #sb_issuer=,
      # then we use that. Otherwise, we default to the default issuer: "owner"
      def sb_issuer
        @sb_issuer || "owner"
      end

      # Public: Get/Set the Service Bus Namespace for this service.
      attr_accessor :sb_namespace

      # Public: Set the host for the Table service. Only set this if you want
      # something custom (like, for example, to point this to a LocalStorage
      # emulator). This should be the complete host, including http:// at the
      # start. When using the emulator, make sure to include your account name at
      # the end.
      #
      # Example:
      #
      #   config.storage_table_host = "http://127.0.0.1:10002/devstoreaccount1"
      attr_writer :storage_table_host

      # Public: Get the host for this service. If you set something using #storage_table_host=,
      # then we use that. Else we default to Azure's default hosts, based
      # on your account name.
      def storage_table_host
        @storage_table_host || default_host(:table)
      end

      # Public: Set the host for the Blob service. Only set this if you want
      # something custom (like, for example, to point this to a LocalStorage
      # emulator). This should be the complete host, including http:// at the
      # start. When using the emulator, make sure to include your account name at
      # the end.
      #
      # Example:
      #
      #   config.storage_blob_host = "http://127.0.0.1:10000/devstoreaccount1"
      attr_writer :storage_blob_host

      # Public: Get the host for this service. If you set something using #storage_blob_host=,
      # then we use that. Else we default to Azure's default hosts, based
      # on your account name.
      def storage_blob_host
        @storage_blob_host || default_host(:blob)
      end

      # Public: Set the host for the Queue service. Only set this if you want
      # something custom (like, for example, to point this to a LocalStorage
      # emulator). This should be the complete host, including http:// at the
      # start. When using the emulator, make sure to include your account name at
      # the end.
      #
      # Example:
      #
      #   config.storage_queue_host = "http://127.0.0.1:10001/devstoreaccount1"
      attr_writer :storage_queue_host

      # Public: Get the host for this service. If you set something using #storage_queue_host=,
      # then we use that. Else we default to Azure's default hosts, based
      # on your account name.
      def storage_queue_host
        @storage_queue_host || default_host(:queue)
      end

      # Public: Get the host for the ACS service.
      def acs_host
        "https://#{sb_namespace}-sb.accesscontrol.windows.net"
      end

      # Public: Get the host for the Service Bus service.
      def service_bus_host
        "https://#{sb_namespace}.servicebus.windows.net"
      end

      # Calculate the default host for a given service in the cloud.
      #
      # service - One of :table, :blob, :queue, etc.
      #
      # Returns a String with the hostname, including your account name.
      def default_host(service)
        "http://#{storage_account_name}.#{service}.core.windows.net"
      end
    end
  end
end
