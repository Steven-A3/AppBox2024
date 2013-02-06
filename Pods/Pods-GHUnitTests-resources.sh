#!/bin/sh

install_resource()
{
  case $1 in
    *.storyboard)
      echo "ibtool --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename $1 .storyboard`.storyboardc ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename $1 .storyboard`.storyboardc" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.xib)
      echo "ibtool --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename $1 .xib`.nib ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename $1 .xib`.nib" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.framework)
      echo "rsync -rp ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -rp "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *)
      echo "cp -R ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
      cp -R "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
      ;;
  esac
}
install_resource 'SSCheckBoxView/SSCheckBoxView/SSCheckBoxView/Graphics/cb_box_off.png'
install_resource 'SSCheckBoxView/SSCheckBoxView/SSCheckBoxView/Graphics/cb_box_off@2x.png'
install_resource 'SSCheckBoxView/SSCheckBoxView/SSCheckBoxView/Graphics/cb_box_on.png'
install_resource 'SSCheckBoxView/SSCheckBoxView/SSCheckBoxView/Graphics/cb_box_on@2x.png'
install_resource 'SSCheckBoxView/SSCheckBoxView/SSCheckBoxView/Graphics/cb_dark_off.png'
install_resource 'SSCheckBoxView/SSCheckBoxView/SSCheckBoxView/Graphics/cb_dark_off@2x.png'
install_resource 'SSCheckBoxView/SSCheckBoxView/SSCheckBoxView/Graphics/cb_dark_on.png'
install_resource 'SSCheckBoxView/SSCheckBoxView/SSCheckBoxView/Graphics/cb_dark_on@2x.png'
install_resource 'SSCheckBoxView/SSCheckBoxView/SSCheckBoxView/Graphics/cb_glossy_off.png'
install_resource 'SSCheckBoxView/SSCheckBoxView/SSCheckBoxView/Graphics/cb_glossy_off@2x.png'
install_resource 'SSCheckBoxView/SSCheckBoxView/SSCheckBoxView/Graphics/cb_glossy_on.png'
install_resource 'SSCheckBoxView/SSCheckBoxView/SSCheckBoxView/Graphics/cb_glossy_on@2x.png'
install_resource 'SSCheckBoxView/SSCheckBoxView/SSCheckBoxView/Graphics/cb_green_off.png'
install_resource 'SSCheckBoxView/SSCheckBoxView/SSCheckBoxView/Graphics/cb_green_off@2x.png'
install_resource 'SSCheckBoxView/SSCheckBoxView/SSCheckBoxView/Graphics/cb_green_on.png'
install_resource 'SSCheckBoxView/SSCheckBoxView/SSCheckBoxView/Graphics/cb_green_on@2x.png'
install_resource 'SSCheckBoxView/SSCheckBoxView/SSCheckBoxView/Graphics/cb_mono_off.png'
install_resource 'SSCheckBoxView/SSCheckBoxView/SSCheckBoxView/Graphics/cb_mono_off@2x.png'
install_resource 'SSCheckBoxView/SSCheckBoxView/SSCheckBoxView/Graphics/cb_mono_on.png'
install_resource 'SSCheckBoxView/SSCheckBoxView/SSCheckBoxView/Graphics/cb_mono_on@2x.png'
install_resource 'XBPageCurl/XBPageCurl/Resources/FragmentShader.glsl'
install_resource 'XBPageCurl/XBPageCurl/Resources/NextPageFragmentShader.glsl'
install_resource 'XBPageCurl/XBPageCurl/Resources/NextPageNoTextureFragmentShader.glsl'
install_resource 'XBPageCurl/XBPageCurl/Resources/NextPageNoTextureVertexShader.glsl'
install_resource 'XBPageCurl/XBPageCurl/Resources/NextPageVertexShader.glsl'
install_resource 'XBPageCurl/XBPageCurl/Resources/VertexShader.glsl'
