#!/bin/sh

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy.txt
touch "$RESOURCES_TO_COPY"

install_resource()
{
  case $1 in
    *.storyboard)
      echo "ibtool --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.xib)
        echo "ibtool --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.framework)
      echo "rsync -rp ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -rp "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename $1 .xcdatamodeld`.momd"
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename $1 .xcdatamodeld`.momd"
      ;;
    *)
      echo "${PODS_ROOT}/$1"
      echo "${PODS_ROOT}/$1" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
install_resource 'JSMessagesViewController/JSMessagesTableViewController/Resources/Images/bubbleSquareIncoming.png'
install_resource 'JSMessagesViewController/JSMessagesTableViewController/Resources/Images/bubbleSquareIncoming@2x.png'
install_resource 'JSMessagesViewController/JSMessagesTableViewController/Resources/Images/bubbleSquareOutgoing.png'
install_resource 'JSMessagesViewController/JSMessagesTableViewController/Resources/Images/bubbleSquareOutgoing@2x.png'
install_resource 'JSMessagesViewController/JSMessagesTableViewController/Resources/Images/input-bar.png'
install_resource 'JSMessagesViewController/JSMessagesTableViewController/Resources/Images/input-bar@2x.png'
install_resource 'JSMessagesViewController/JSMessagesTableViewController/Resources/Images/input-field.png'
install_resource 'JSMessagesViewController/JSMessagesTableViewController/Resources/Images/input-field@2x.png'
install_resource 'JSMessagesViewController/JSMessagesTableViewController/Resources/Images/messageBubbleBlue.png'
install_resource 'JSMessagesViewController/JSMessagesTableViewController/Resources/Images/messageBubbleBlue@2x.png'
install_resource 'JSMessagesViewController/JSMessagesTableViewController/Resources/Images/messageBubbleGray.png'
install_resource 'JSMessagesViewController/JSMessagesTableViewController/Resources/Images/messageBubbleGray@2x.png'
install_resource 'JSMessagesViewController/JSMessagesTableViewController/Resources/Images/messageBubbleGreen.png'
install_resource 'JSMessagesViewController/JSMessagesTableViewController/Resources/Images/messageBubbleGreen@2x.png'
install_resource 'JSMessagesViewController/JSMessagesTableViewController/Resources/Images/messageBubbleHighlighted.png'
install_resource 'JSMessagesViewController/JSMessagesTableViewController/Resources/Images/messageBubbleHighlighted@2x.png'
install_resource 'JSMessagesViewController/JSMessagesTableViewController/Resources/Images/messageBubbleTyping.png'
install_resource 'JSMessagesViewController/JSMessagesTableViewController/Resources/Images/messageBubbleTyping@2x.png'
install_resource 'JSMessagesViewController/JSMessagesTableViewController/Resources/Images/send-highlighted.png'
install_resource 'JSMessagesViewController/JSMessagesTableViewController/Resources/Images/send-highlighted@2x.png'
install_resource 'JSMessagesViewController/JSMessagesTableViewController/Resources/Images/send.png'
install_resource 'JSMessagesViewController/JSMessagesTableViewController/Resources/Images/send@2x.png'
install_resource 'JSMessagesViewController/JSMessagesTableViewController/Resources/Sounds/messageReceived.aiff'
install_resource 'JSMessagesViewController/JSMessagesTableViewController/Resources/Sounds/messageSent.aiff'
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

rsync -avr --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
rm "$RESOURCES_TO_COPY"
