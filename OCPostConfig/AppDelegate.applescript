--
--  AppDelegate.applescript
--  OCPostConfig
--
--  Created by Iron Man on 2020-05-18.
--  Copyright © 2020 Iron Man Labs. All rights reserved.
--

script AppDelegate
	property parent : class "NSObject"
	
	-- IBOutlets
	property theWindow : missing value

    property OpenCoreVersion : "Unknown"
    property BootPath : "Unknown"
    property OemProduct : "Unknown"
    property OemVendor : "Unknown"
    property OemBoard : "Unknown"
    property Config : "Unknown"
    property SystemProductName : missing value
    property SystemProductNameItems : {"iMac13,2", "MacMini6,2"}
    property SystemProductNameEnabled : false

    property PickerMode : missing value
    property ShowPicker : false
    property PickerModeItems : {"Builtin", "External"}

    property PickerTimeout : missing value

    property BootArgs : ""
	
	on applicationWillFinishLaunching_(aNotification)
		-- Insert code here to initialize your application before any files are opened
        
        -- GET OPENCORE VERSION AND SET IT INTERFACE
        set OpenCoreVersion to ( do shell script "nvram 4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102:opencore-version | awk '{print $2}'" )
        -- Sets the value in the interface
        setOpenCoreVersion_(OpenCoreVersion as string)
        
        set BootPath to ( do shell script "nvram 4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102:boot-path | awk '{print $2}'" )
        set OemProduct to ( do shell script "nvram 4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102:oem-product | awk '{print $2}'" )
        set OemVendor to ( do shell script "nvram 4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102:oem-vendor | awk '{print $2}'" )
        set OemBoard to ( do shell script "nvram 4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102:oem-board | awk '{print $2}'" )
        if OemBoard is not "Z77MX-QUO-AOS" then
            display alert "This utility is not safe to use on other motherboard because of assumptions made"
            quit
        end if

        -- OPEN AND READ THE CONFIG.PLIST FILE
        set theStatusText to "Please choose the Config.plist file to affect."
        set theTask to (current application's NSTask's launchedTaskWithLaunchPath:"/usr/bin/say" arguments:{theStatusText})
        try
            set Config to quoted form of (POSIX path of ( choose file with prompt "Please select Config.plist:" of type {"plist"} ))
            theTask's terminate()
        on error
            try
                theTask's terminate()
            end try
            quit
        end try

        --   VERIFY THAT THE PLIST IS AT LEAST VALID -- WILL RETURN EMPTY STRING ON SUCCESS
        set validPlist to (do shell script "plutil -s " & Config )
        if validPlist is not "" then
            display alert "This file is not a valid plist file"
            quit
        end if

        --   GET SMBIOS AND SET IT INTERFACE
        set theSystemProductName to (do shell script "/usr/libexec/PlistBuddy -c \"Print :PlatformInfo:Generic:SystemProductName \" " & Config )
        if theSystemProductName is not in SystemProductNameItems then
            display alert "SMBIOS IS NOT SUPPORTED " &theSystemProductName
            quit
        end if
        setSystemProductName_(theSystemProductName as string)

        set theShowPicker to (do shell script "/usr/libexec/PlistBuddy -c \"Print :Misc:Boot:ShowPicker \" " & Config )
        setShowPicker_(theShowPicker as boolean)
        
        set thePickerMode to (do shell script "/usr/libexec/PlistBuddy -c \"Print :Misc:Boot:PickerMode \" " & Config )
        setPickerMode_(thePickerMode as string)
        
        set theTimeout    to (do shell script "/usr/libexec/PlistBuddy -c \"Print :Misc:Boot:Timeout \" " & Config )
        setPickerTimeout_(theTimeout as integer)

        set theBootArgs    to (do shell script "/usr/libexec/PlistBuddy -c \"Print :NVRAM:Add:7C436110-AB2A-4BBB-A880-FE41995C9F82:boot-args \" " & Config )
        setBootArgs_(theBootArgs as string)

       	end applicationWillFinishLaunching_
	
	on applicationShouldTerminate_(sender)
		-- Insert code here to do any housekeeping before your application quits 
		return current application's NSTerminateNow
	end applicationShouldTerminate_
	
    on pitonDone_(sender)

--        setOpenCoreVersion_(OpenCoreVersion as string)
--        set bootArgs to (do shell script "/usr/libexec/PlistBuddy -c \"Print :NVRAM:Add:7C436110-AB2A-4BBB-A880-FE41995C9F82:boot-args \" " & Config )
--        display alert "Picker Timeout : " & PickerTimeout & "\n"  & ¬
                    "OEM Board : " & OemBoard & "\n" & ¬
                    "Boot Path : " & BootPath
        quit
    end pitonDone_

    on pitonSMBIOS_(sender)
        
    end pitonSMBIOS_

    on pitonBootPicker_(sender)
        if ShowPicker as boolean is true then
--            display alert "ShowPicker True"
            do shell script ("/usr/libexec/PlistBuddy -c \"Set :Misc:Boot:ShowPicker true\" " & Config)
        else
--            display alert "ShowPicker False"
            do shell script ("/usr/libexec/PlistBuddy -c \"Set :Misc:Boot:ShowPicker false\" " & Config)
        end if
    end pitonBootPicker_

    on pitonPickerMode_(sender)
        if PickerMode as string = "Builtin" then
--            display alert "PickerMode Builtin"
            do shell script ("/usr/libexec/PlistBuddy -c \"Set :Misc:Boot:PickerMode Builtin\" " & Config)
        else
--            display alert "PickerMode External" &PickerMode
            do shell script ("/usr/libexec/PlistBuddy -c \"Set :Misc:Boot:PickerMode External\" " & Config)
        end if
    end pitonPickerMode_

    on pitonPickerTimeout_(sender)
--        display alert "Timeout is " & PickerTimeout
        set x to PickerTimeout as string
        do shell script ("/usr/libexec/PlistBuddy -c \"Set :Misc:Boot:Timeout " & x & "\" " & Config)
    end pitonPickerTimeout_

    on pitonBootArgs_(sender)
        set x to BootArgs as string
        do shell script ("/usr/libexec/PlistBuddy -c \"Set :NVRAM:Add:7C436110-AB2A-4BBB-A880-FE41995C9F82:boot-args " & x & "\" " & Config)
    end pitonBootArgs_


end script
