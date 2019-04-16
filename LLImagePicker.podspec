Pod::Spec.new do |s|
	s.name      			= 'LLImagePicker'
	s.version   			= '0.0.1'
	s.summary   			= '图片选取器，支持图片多选，视频、图片、GIF筛选'
	s.homepage  			= 'https://github.com/LOLITA0164/LLImagePicker'
	s.license   			= 'MIT'
	s.platform  			= :ios
	s.author    			= {'LOLITA0164' => '476512340@qq.com'}
	s.ios.deployment_target = '9.0'
	s.source    			= {:git => 'https://github.com/LOLITA0164/LLImagePicker.git', :tag => s.version}
	s.source_files  		= 'LLImagePicker/LLImagePicker/*.{swift}'
	s.resources  			= 'LLImagePicker/LLImagePicker/*.{xcassets,storyboard}'
	s.swift_version 		= '4.2'
	s.frameworks    		= 'UIKit', 'Foundation', 'Photos'
	s.dependency 'SnapKit'
	s.subspec 'public' do |ss|
		ss.source_files  		= 'LLImagePicker/LLImagePicker/public/*.{swift}'
	end
end
