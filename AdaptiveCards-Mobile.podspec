Pod::Spec.new do |s|
  s.name             = 'AdaptiveCards-Mobile'
  s.version          = '2.0.0'
  s.summary          = 'Cross-platform Adaptive Cards v1.6 rendering SDK for iOS'
  s.description      = <<-DESC
    SwiftUI-based rendering library for Adaptive Cards v1.6. Provides standalone parsing,
    configurable rendering, built-in caching, and Teams integration adapters.
  DESC

  s.homepage         = 'https://github.com/AzureAD/AdaptiveCards-Mobile'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Microsoft' => 'AzureAD@microsoft.com' }
  s.source           = { :git => 'https://github.com/AzureAD/AdaptiveCards-Mobile.git', :tag => s.version.to_s }

  s.ios.deployment_target = '16.0'
  s.swift_version = '5.9'

  # --- Subspecs ---

  s.subspec 'ACCore' do |core|
    core.source_files = 'ios/Sources/ACCore/**/*.swift'
    core.resource_bundles = { 'ACCore' => ['ios/Sources/ACCore/Resources/**/*'] }
  end

  s.subspec 'ACAccessibility' do |acc|
    acc.source_files = 'ios/Sources/ACAccessibility/**/*.swift'
    acc.dependency 'AdaptiveCards-Mobile/ACCore'
  end

  s.subspec 'ACTemplating' do |tmpl|
    tmpl.source_files = 'ios/Sources/ACTemplating/**/*.swift'
    tmpl.dependency 'AdaptiveCards-Mobile/ACCore'
  end

  s.subspec 'ACMarkdown' do |md|
    md.source_files = 'ios/Sources/ACMarkdown/**/*.swift'
  end

  s.subspec 'ACFluentUI' do |fluent|
    fluent.source_files = 'ios/Sources/ACFluentUI/**/*.swift'
  end

  s.subspec 'ACCharts' do |charts|
    charts.source_files = 'ios/Sources/ACCharts/**/*.swift'
    charts.dependency 'AdaptiveCards-Mobile/ACCore'
    charts.dependency 'AdaptiveCards-Mobile/ACFluentUI'
  end

  s.subspec 'ACInputs' do |inputs|
    inputs.source_files = 'ios/Sources/ACInputs/**/*.swift'
    inputs.dependency 'AdaptiveCards-Mobile/ACCore'
    inputs.dependency 'AdaptiveCards-Mobile/ACAccessibility'
  end

  s.subspec 'ACActions' do |actions|
    actions.source_files = 'ios/Sources/ACActions/**/*.swift'
    actions.dependency 'AdaptiveCards-Mobile/ACCore'
    actions.dependency 'AdaptiveCards-Mobile/ACAccessibility'
    actions.dependency 'AdaptiveCards-Mobile/ACFluentUI'
  end

  s.subspec 'ACRendering' do |rendering|
    rendering.source_files = 'ios/Sources/ACRendering/**/*.swift'
    rendering.dependency 'AdaptiveCards-Mobile/ACCore'
    rendering.dependency 'AdaptiveCards-Mobile/ACInputs'
    rendering.dependency 'AdaptiveCards-Mobile/ACActions'
    rendering.dependency 'AdaptiveCards-Mobile/ACAccessibility'
    rendering.dependency 'AdaptiveCards-Mobile/ACMarkdown'
    rendering.dependency 'AdaptiveCards-Mobile/ACCharts'
    rendering.dependency 'AdaptiveCards-Mobile/ACFluentUI'
    rendering.dependency 'AdaptiveCards-Mobile/ACTemplating'
  end

  s.subspec 'ACCopilotExtensions' do |copilot|
    copilot.source_files = 'ios/Sources/ACCopilotExtensions/**/*.swift'
    copilot.dependency 'AdaptiveCards-Mobile/ACCore'
  end

  s.subspec 'ACTeams' do |teams|
    teams.source_files = 'ios/Sources/ACTeams/**/*.swift'
    teams.dependency 'AdaptiveCards-Mobile/ACCore'
    teams.dependency 'AdaptiveCards-Mobile/ACRendering'
  end

  # Default subspecs for simple installation
  s.default_subspecs = ['ACCore', 'ACRendering']
end
