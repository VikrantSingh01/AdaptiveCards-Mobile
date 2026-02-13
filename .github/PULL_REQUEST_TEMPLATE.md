# Pull Request

## Description

<!-- Provide a brief description of the changes in this PR -->

## Type of Change

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Code refactoring

## Cross-Platform Parity Checklist

**For all code changes affecting card rendering or schema support:**

- [ ] **iOS Implementation**: Changes implemented in iOS (Swift/SwiftUI)
- [ ] **Android Implementation**: Changes implemented in Android (Kotlin/Compose)
- [ ] **Tests Added**: Tests added for both platforms
- [ ] **Schema Updated**: SchemaValidator updated on both platforms (if new elements/actions)
- [ ] **PARITY_MATRIX.md Updated**: Documentation reflects current implementation status
- [ ] **Shared Test Card**: Added/updated test card in `shared/test-cards/` (if applicable)
- [ ] **Parity Gate Passes**: CI parity gate passes (iOS + Android tests)

## Testing Checklist

- [ ] **Unit Tests**: Added/updated unit tests
- [ ] **Integration Tests**: Added/updated integration tests
- [ ] **All Tests Pass**: `swift test` (iOS) and `./gradlew test` (Android) pass locally
- [ ] **Test Coverage**: Maintained or improved test coverage
- [ ] **Manual Testing**: Manually tested changes on iOS and Android
- [ ] **Edge Cases**: Tested edge cases and error conditions

## Schema Validation (for schema changes)

- [ ] **v1.6 Compliance**: Changes comply with Adaptive Cards v1.6 spec
- [ ] **Schema File Updated**: `shared/schema/adaptive-card-schema-1.6.json` updated (if applicable)
- [ ] **Round-Trip Tests**: JSON parse → model → JSON serialization works correctly
- [ ] **Unknown Elements**: Unknown elements handled gracefully

## Documentation

- [ ] **Code Comments**: Added comments for complex logic
- [ ] **README Updated**: Updated relevant README files
- [ ] **Architecture Docs**: Updated architecture docs (if applicable)
- [ ] **CHANGELOG Updated**: Added entry to CHANGELOG.md
- [ ] **API Documentation**: Updated API documentation (if public API changed)

## Accessibility

- [ ] **Screen Reader**: Works with VoiceOver (iOS) and TalkBack (Android)
- [ ] **Dynamic Type**: Respects system font size preferences
- [ ] **Touch Targets**: Minimum 44x44pt (iOS) / 48x48dp (Android)
- [ ] **Contrast**: Meets WCAG 2.1 AA contrast requirements
- [ ] **Semantic Labels**: Proper accessibility labels and hints

## Performance

- [ ] **No Performance Regression**: Changes do not negatively impact performance
- [ ] **Memory Leaks**: Checked for memory leaks
- [ ] **Large Card Handling**: Tested with large/complex cards

## Security

- [ ] **No Security Vulnerabilities**: Changes do not introduce security issues
- [ ] **Input Validation**: User input properly validated
- [ ] **XSS Prevention**: Protected against cross-site scripting (if applicable)
- [ ] **Secrets**: No secrets or sensitive data in code

## Breaking Changes

<!-- If this PR includes breaking changes, describe them here and provide migration guidance -->

## Screenshots / Videos

<!-- Add screenshots or videos demonstrating the changes, especially for UI changes -->

## Related Issues

<!-- Link to related issues: Fixes #123, Closes #456 -->

## Additional Notes

<!-- Any additional information that reviewers should know -->

---

## Reviewer Checklist

**For Maintainers:**

- [ ] Code quality meets project standards
- [ ] Cross-platform parity maintained
- [ ] Tests are comprehensive and passing
- [ ] Documentation is clear and complete
- [ ] No breaking changes (or properly documented)
- [ ] CHANGELOG.md updated appropriately
- [ ] CI checks pass (lint, tests, parity gate)
