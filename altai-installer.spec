Name:             altai-installer
Version:          1.0
Release:          0
Summary:          Installer for Altai
License:          GNU LGPL 2.1
Vendor:           Grid Dynamics International, Inc.
URL:              http://www.griddynamics.com/openstack
Group:            Development

Source0:          %{name}-%{version}.tar.gz
BuildRoot:        %{_tmppath}/%{name}-%{version}-build
BuildArch:        noarch
Requires:         altai-chef-gems


%description
Chef-based installer for Altai


%prep
%setup -q -n %{name}-%{version}


%build


%install
rm -rf %{buildroot}
mkdir -p %{buildroot}/opt/altai
cp -a * %{buildroot}/opt/altai
rm -f %{buildroot}/opt/altai/COPYING*


%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)
%doc COPYING*
/opt/altai


%changelog
