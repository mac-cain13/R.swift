// Release script does the following steps:
//
// Run tests:
// 1. Run tests for R.swift
// 2. Run tests for R.swift.Library
// 3. Run tests for ResourceApp test project
//
// If the current HEAD isn't a tag already:
// 4. Ask version number for R.swift.Library
// 5. Update the podspec
// 6. Commit + tag
// 7. Push
// 8. Upload release notes to Github releases
// 9. `pod trunk push`
//
// If the current HEAD isn't a tag already or when R.swift.Library has a newer version:
// 10. Ask version for R.swift + release notes
// 11. Update the podspec (our version and the R.swift.Library dependency version)
// 12. Commit + tag
// 13. Archive R.swift
// 14. Create zipfile
// 15. Push
// 16. Upload zip + release notes to Github releases
// 17. `pod trunk push`