require 'xcodeproj'

class String
def black;          "\e[30m#{self}\e[0m" end
def red;            "\e[31m#{self}\e[0m" end
def green;          "\e[32m#{self}\e[0m" end
def brown;          "\e[33m#{self}\e[0m" end
def blue;           "\e[34m#{self}\e[0m" end
def magenta;        "\e[35m#{self}\e[0m" end
def cyan;           "\e[36m#{self}\e[0m" end
def gray;           "\e[37m#{self}\e[0m" end

def bg_black;       "\e[40m#{self}\e[0m" end
def bg_red;         "\e[41m#{self}\e[0m" end
def bg_green;       "\e[42m#{self}\e[0m" end
def bg_brown;       "\e[43m#{self}\e[0m" end
def bg_blue;        "\e[44m#{self}\e[0m" end
def bg_magenta;     "\e[45m#{self}\e[0m" end
def bg_cyan;        "\e[46m#{self}\e[0m" end
def bg_gray;        "\e[47m#{self}\e[0m" end

def bold;           "\e[1m#{self}\e[22m" end
def italic;         "\e[3m#{self}\e[23m" end
def underline;      "\e[4m#{self}\e[24m" end
def blink;          "\e[5m#{self}\e[25m" end
def reverse_color;  "\e[7m#{self}\e[27m" end
end

# Constants
EMBED_CARTHAGE_FRAMEWORKS_NAME = "Embed Carthage Frameworks"
OTHER_LINKER_FLAGS = "$(inherited) -enable-bridging-pch"
FRAMEWORK_SEARCH_PATHS = "$(inherited) $(PROJECT_DIR)/Carthage/Build/iOS"
REMOVE_UNWANTED_FRAMEWORK_ARCHITECTURES = "Remove Unwanted Framework Architectures"
REMOVE_UNWANTED_FRAMEWORK_ARCHITECTURES_SCRIPT = '
if [ "${CONFIGURATION}" = "Release" ]; then
  APP_PATH="${TARGET_BUILD_DIR}/${WRAPPER_NAME}"

  # This script loops through the frameworks embedded in the application and
  # removes unused architectures.
  find "$APP_PATH" -name \'*.framework\' -type d | while read -r FRAMEWORK
  do
  FRAMEWORK_EXECUTABLE_NAME=$(defaults read "$FRAMEWORK/Info.plist" CFBundleExecutable)
  FRAMEWORK_EXECUTABLE_PATH="$FRAMEWORK/$FRAMEWORK_EXECUTABLE_NAME"
  echo "Executable is $FRAMEWORK_EXECUTABLE_PATH"

  EXTRACTED_ARCHS=()

  for ARCH in $ARCHS
  do
  echo "Extracting $ARCH from $FRAMEWORK_EXECUTABLE_NAME"
  lipo -extract "$ARCH" "$FRAMEWORK_EXECUTABLE_PATH" -o "$FRAMEWORK_EXECUTABLE_PATH-$ARCH"
  EXTRACTED_ARCHS+=("$FRAMEWORK_EXECUTABLE_PATH-$ARCH")
  done

  echo "Merging extracted architectures: ${ARCHS}"
  lipo -o "$FRAMEWORK_EXECUTABLE_PATH-merged" -create "${EXTRACTED_ARCHS[@]}"
  rm "${EXTRACTED_ARCHS[@]}"

  echo "Replacing original executable with thinned version"
  rm "$FRAMEWORK_EXECUTABLE_PATH"
  mv "$FRAMEWORK_EXECUTABLE_PATH-merged" "$FRAMEWORK_EXECUTABLE_PATH"

  done
fi'

projectNames = Dir["../*.xcodeproj"]

if projectNames.nil?
	abort("Does not exist project to config!")
end

puts "💎💎  Project Found -> #{projectNames.first} 💎💎"

# Variables
@project = Xcodeproj::Project.open(projectNames.first)

puts "opened"

# Methods
def create_embed_frameworks_build_phase
	build_phase = @project.new(Xcodeproj::Project::Object::PBXCopyFilesBuildPhase)
  	build_phase.name = EMBED_CARTHAGE_FRAMEWORKS_NAME
  	build_phase.symbol_dst_subfolder_spec = :frameworks
  	return build_phase
end

def create_shell_script_build_phase(name)
	build_phase = @project.new(Xcodeproj::Project::Object::PBXShellScriptBuildPhase)
  	build_phase.name = name
  	return build_phase
end

def add_embedded_binaries(build_phase)
	input_paths = []

	Dir.entries('../Carthage/Build/iOS').each do |entry|
		matched = /^(.*)\.framework$/.match(entry)

		if !matched.nil?
 			frameworks_group = @project.groups.find { |group| group.display_name == 'Frameworks' }
			framework_ref = frameworks_group.new_file("Carthage/Build/iOS/#{matched.string}")
    		build_file = build_phase.add_file_reference(framework_ref)
    		build_file.settings = { 'ATTRIBUTES' => ['CodeSignOnCopy', 'RemoveHeadersOnCopy'] }
    		input_paths.push("${SRCROOT}/Carthage/Build/iOS/#{matched.string}")
			puts "framework_ref -> #{framework_ref}".gray
		end
	end
end

def add_input_files(build_phase)
	input_paths = []

	Dir.entries('../Carthage/Build/iOS').each do |entry|
		matched = /^(.*)\.framework$/.match(entry)
		if !matched.nil?
    		input_paths.push("${SRCROOT}/Carthage/Build/iOS/#{matched.string}")
		end
	end

	build_phase.input_paths = input_paths

	puts "add input files to run script -> #{input_paths}".gray
end

def write_xcodeproj
	puts "🙏  Start xconfig..".green

	new_build_phase = nil
	new_arch_build_phase = nil

	@project.targets.each do |target|
		puts "👻  build target -> #{target.name}"

		exist_build_phase = target.build_phases.find { |build_phase| build_phase.class == Xcodeproj::Project::Object::PBXCopyFilesBuildPhase && build_phase.name == EMBED_CARTHAGE_FRAMEWORKS_NAME }
		exist_arch_build_phase = target.build_phases.find { |build_phase| build_phase.class == Xcodeproj::Project::Object::PBXShellScriptBuildPhase && build_phase.name == REMOVE_UNWANTED_FRAMEWORK_ARCHITECTURES }

		if !exist_build_phase.nil?
			puts "delete exist embed carthage framework".gray
			exist_build_phase.files_references.each do |reference|
				reference.remove_from_project
			end
			exist_build_phase.clear
			target.build_phases.delete(exist_build_phase)
		end

		if new_build_phase.nil?
  			new_build_phase = create_embed_frameworks_build_phase
			add_embedded_binaries(new_build_phase)
			puts "create new embed carthage framework -> #{new_build_phase}".gray
		end

		if !exist_arch_build_phase.nil?
			puts "delete exist remove unwanted framework architectures".gray
			exist_arch_build_phase.clear
			target.build_phases.delete(exist_arch_build_phase)
		end

		if new_arch_build_phase.nil?
			new_arch_build_phase = create_shell_script_build_phase(REMOVE_UNWANTED_FRAMEWORK_ARCHITECTURES)
			new_arch_build_phase.shell_script =  REMOVE_UNWANTED_FRAMEWORK_ARCHITECTURES_SCRIPT
			# add_input_files(new_arch_build_phase)
			puts "create new remove unwanted framework architectures -> #{new_arch_build_phase}".gray
		end

		target.build_phases << new_build_phase
		target.build_phases << new_arch_build_phase

		puts "#{target.build_configurations}"

	  target.build_configurations.each do |config|
	    config.build_settings['FRAMEWORK_SEARCH_PATHS'] = FRAMEWORK_SEARCH_PATHS
			puts "#{config}: set up FRAMEWORK_SEARCH_PATHS of build_settings to #{FRAMEWORK_SEARCH_PATHS}".gray
	 	end
		puts "\n"
	end

	@project.save()

	puts "👌  Finish xconfig..".green
end

write_xcodeproj()
