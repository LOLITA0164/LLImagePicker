Pod::Spec.new do |s|
	s.name      			= 'LLPhotosPicker'
	s.version   			= '0.0.7'
	s.summary   			= '图片选取器，支持图片多选，视频、图片、GIF筛选'
	s.homepage  			= 'https://github.com/LOLITA0164/LLPhotosPicker'
	s.license   			= 'MIT'
	s.platform  			= :ios
	s.author    			= {'LOLITA0164' => '476512340@qq.com'}
	s.ios.deployment_target = '9.0'
	s.source    			= {:git => 'https://github.com/LOLITA0164/LLPhotosPicker.git', :tag => s.version}
	s.source_files  		= 'LLPhotosPicker/PhotosPicker/*.{swift}'
	s.resources  			= 'LLPhotosPicker/PhotosPicker/*.{bundle}'
	s.resource_bundles 		= {
		'LLPhotosPicker' => [
			'LLPhotosPicker/PhotosPicker/*.{xib}',
		]
	}
	s.swift_version 		= '4.2'
	s.frameworks    		= 'UIKit', 'Foundation', 'Photos'
	s.dependency 'SnapKit', '~> 4.2.0'
	s.subspec 'public' do |ss|
        ss.source_files 	= 'LLPhotosPicker/PhotosPicker/public/*.{swift}'
    end
end
