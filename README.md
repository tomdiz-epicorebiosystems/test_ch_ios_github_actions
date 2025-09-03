## Connected_Hydration_iOSApp

Epicore Biosystems Connected Hydration v2 iOS Application

# Build

To build this proiect just clone to a new folder. Open "Connected_Hydration_iOS.xcodeproj" and build/run.


# Upload dSym to Datadog after upload to iTunes

- Installing @datadog/datadog-ci - requires homebrew/node/yarn/ [Datadog CI Info](https://www.npmjs.com/package/@datadog/datadog-ci)

- How to find dsym file after create archive [XCode Info](https://stackoverflow.com/questions/7088771/iphone-where-the-dsym-file-is-located-in-crash-report)

- Once find dsym folder open and ZIP "Connected_Hydration_iOS.app.dSYM"

- Bash commands - export these variables and run npx
```
% export DATADOG_API_KEY="ab9632bfee721936fc5e68fb9a8e2ab7"

% export DATADOG_SITE="us5.datadoghq.com"

% npx @datadog/datadog-ci dsyms upload Connected_Hydration_iOS.app.dSYM.zip
```