require 'puppet/parameter/name'
require 'puppet/property/address'
require 'puppet/property/availability'
require 'puppet/property/connection_limit'
require 'puppet/property/connection_rate_limit'
require 'puppet/property/description'
require 'puppet/property/monitor'
require 'puppet/property/ratio'
require 'puppet/property/state'

Puppet::Type.newtype(:f5_node) do
  @doc = 'Manage node objects'

  apply_to_device
  ensurable

  newparam(:name, :parent => Puppet::Parameter::F5Name, :namevar => true)
  newproperty(:address, :parent => Puppet::Property::F5Address)
  newproperty(:state, :parent => Puppet::Property::F5State)
  newproperty(:description, :parent => Puppet::Property::F5Description)

  newproperty(:logging) do
    desc 'The logging state of the node object.
    Valid options:  <disabled|enabled|true|false>'

    newvalues(:disabled, :enabled, :true, :false)
  end

  newproperty(:monitor, :array_matching => :all, :parent => Puppet::Property::F5Monitor)
  newproperty(:availability, :parent => Puppet::Property::F5Availability)
  newproperty(:ratio, :parent => Puppet::Property::F5Ratio)
  newproperty(:connection_limit, :parent => Puppet::Property::F5ConnectionLimit)
  newproperty(:connection_rate_limit, :parent => Puppet::Property::F5ConnectionRateLimit)

  validate do
    if ! self[:monitor] && self[:availability]
      fail ArgumentError, 'ERROR:  Availability cannot be set when no monitor is assigned.'
    end

    # You can't have a minimum of more than the total number of monitors.
    if self[:availability] =~ /\d+/
      if Array(self[:monitor]).count < self[:availability].to_i
        fail ArgumentError, 'ERROR:  Availability count cannot be more than the total number of monitors.'
      end
    end

    if self[:monitor].is_a?(Array) && ! self[:availability]
      fail ArgumentError, 'ERROR:  Availability must be set when monitors are assigned.'
    end
  end

end
