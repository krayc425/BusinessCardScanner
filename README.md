# BusinessCardScanner

A business card scanner demo using ABBYY / Camcard API.

# Usage

1. Run `pod install`

2. Open `BusinessCardScanner.xcworkspace`

3. Add your ABBYY / Camcard keys into `Keys.swift`
    
    ```swift
    struct CamcardKeys {
        
        static let pin = ""
        static let user = ""
        static let pass = ""
        
    }
    
    struct ABBYYKeys {
        
        static let id = ""
        static let password = ""
        
    }
    ```
    
4. Run and have fun!