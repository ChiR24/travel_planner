# Contributing to Travel Planner

Thank you for your interest in contributing to the Travel Planner project! This document provides guidelines and instructions for contributing.

## Table of Contents
- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Environment Setup](#development-environment-setup)
- [Coding Standards](#coding-standards)
- [Submitting Changes](#submitting-changes)
- [Pull Request Process](#pull-request-process)
- [Testing Guidelines](#testing-guidelines)
- [Documentation](#documentation)

## Code of Conduct

Please be respectful and considerate of others when contributing to this project. We aim to foster an inclusive and welcoming community.

## Getting Started

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR-USERNAME/travel_planner.git
   ```
3. Add the upstream repository:
   ```bash
   git remote add upstream https://github.com/ChiR24/travel_planner.git
   ```
4. Create a new branch for your feature or bugfix:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Environment Setup

1. Install Flutter and Dart SDK:
   - Follow the [official Flutter installation guide](https://flutter.dev/docs/get-started/install)
   - Ensure you're using Flutter version 3.19.0 or later

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure environment variables:
   - Create a `.env` file in the project root (see `.env.example` for required variables)
   - Obtain API keys for:
     - Weather API
     - Google Maps
     - Mapbox

4. Run the app in debug mode:
   ```bash
   flutter run
   ```

## Coding Standards

This project follows Flutter's recommended coding standards:

1. Use the official [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
2. Run the formatter before committing:
   ```bash
   dart format .
   ```
3. Ensure code passes linting:
   ```bash
   flutter analyze
   ```
4. Follow the project's architecture pattern (feature-first with providers)
5. Write clear and concise comments

## Submitting Changes

1. Make your changes in your feature branch
2. Add and commit your changes with a descriptive commit message:
   ```bash
   git add .
   git commit -m "Feature: Add detailed description of your changes"
   ```
3. Pull the latest changes from upstream:
   ```bash
   git pull upstream main
   ```
4. Resolve any conflicts and commit the changes
5. Push your changes to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

## Pull Request Process

1. Create a Pull Request (PR) from your fork to the main repository
2. Provide a detailed description of your changes
3. Reference any related issues using the GitHub issue number (e.g., "Fixes #123")
4. Wait for code review and address any feedback
5. Once approved, your PR will be merged

## Testing Guidelines

1. Write unit tests for new functionality
2. Ensure existing tests pass:
   ```bash
   flutter test
   ```
3. For UI components, add widget tests
4. Consider adding integration tests for critical workflows

## Documentation

1. Update documentation for any changed functionality
2. Document new features with clear examples
3. Include comments for complex code sections
4. Update the README.md if necessary

Thank you for contributing to the Travel Planner project! 