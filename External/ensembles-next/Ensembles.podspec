Pod::Spec.new do |s|

  s.name         = "Ensembles"
  s.version      = "2.0"
  s.summary      = "A peer-to-peer synchronization framework for Core Data."

  s.description  =  <<-DESC
                    Ensembles extends Apple's Core Data framework to add 
                    peer-to-peer synchronization for Mac OS and iOS. 
                    Multiple SQLite persistent stores can be coupled together 
                    via a file synchronization platform like iCloud, Dropbox,
                    or even Multipeer Connectivity. 
                    The framework can be readily extended to support any 
                    service capable of moving files between devices, including 
                    custom servers.
                    DESC

  s.homepage = "https://github.com/drewmccormack/ensembles"
  s.license = { 
    :type => 'MIT', 
    :file => 'LICENCE.md' 
  }
  s.author = { "Drew McCormack" => "drewmccormack@mac.com" }
  
  s.ios.deployment_target = '6.0'
  s.osx.deployment_target = '10.7'

  s.source        = { 
    :git => 'https://github.com/mentalfaculty/ensembles-next.git', 
    :tag => s.version.to_s
  }
  
  s.requires_arc  = true
  
  s.default_subspec = 'Core'
  
  s.subspec 'Core' do |ss|
    ss.source_files = 'Framework/**/*.{h,m}'
    ss.exclude_files = 'Framework/Tests', 'Framework/Profiling', 'Framework/Extensions'
    ss.resources = 'Framework/Resources/*'
    ss.frameworks = 'CoreData'
  end
  
  s.subspec 'Dropbox' do |ss|
    ss.dependency 'Ensembles/Core'
    ss.ios.dependency 'Dropbox-iOS-SDK'
    ss.osx.dependency 'Dropbox-OSX-SDK'
    ss.source_files = 'Framework/Extensions/CDEDropboxCloudFileSystem.{h,m}'
  end

  s.subspec 'Multipeer' do |ss|
    ss.dependency 'Ensembles/Core'
    ss.dependency 'SSZipArchive'
    ss.framework = 'MultipeerConnectivity'
    ss.source_files = 'Framework/Extensions/CDEMultipeerCloudFileSystem.{h,m}'
    s.ios.deployment_target = '7.0'
    s.osx.deployment_target = '10.10'
  end

  s.subspec 'WebDAV' do |ss|
    ss.dependency 'Ensembles/Core'
    ss.source_files = 'Framework/Extensions/CDEWebDavCloudFileSystem.{h,m}'
  end

  s.subspec 'Zip' do |ss|
    ss.dependency 'Ensembles/Core'
    ss.dependency 'SSZipArchive'
    ss.source_files = 'Framework/Extensions/CDEZipCloudFileSystem.{h,m}'
  end

  s.subspec 'Node' do |ss|
    ss.dependency 'Ensembles/Core'
    ss.source_files = 'Framework/Extensions/CDENodeCloudFileSystem.{h,m}'
  end

end