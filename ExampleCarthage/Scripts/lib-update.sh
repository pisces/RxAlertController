if ! gem spec xcodeproj > /dev/null 2>&1; then
	sudo gem install xcodeproj
fi

if ! brew ls --versions carthage > /dev/null 2>&1; then
	brew install carthage
fi

useclean=false
buildonly=false

for i in "$@"
do
case $i in
	--use-clean)
		useclean=true ;;
	--build-only)
		buildonly=true ;;
esac
done

cd ..

echo "buildonly: $buildonly, useclean: $useclean"

if $buildonly; then
	XCODE_XCCONFIG_FILE="Carthage.xcconfig" carthage build --platform ios --verbose
else
	if $useclean; then
		rm -rf ./Carthage
	fi

	XCODE_XCCONFIG_FILE="Carthage.xcconfig" carthage update --platform ios --verbose
fi

cd Scripts
ruby carthage_xconfig.rb
