# PROJECT_PROMPT.md

## Project Name

Smart Farm Application

## Objective

Build a complete Smart Farm Irrigation Platform using Flutter as a single codebase for:

* Android App
* iOS App
* Web Dashboard

The application communicates with a PHP Backend hosted on Shared Hosting.

The system manages:

* Borewell
* Open Well
* Four Irrigation Zones
* Soil Moisture Monitoring
* Weather Monitoring
* Water Usage Tracking
* Irrigation Scheduling
* Alerts and Notifications
* Automation Engine

---

## Technology Stack

Frontend:

* Flutter Latest Stable
* Dart
* Provider State Management
* Responsive Framework
* HTTP Client
* Flutter Secure Storage
* fl_chart

Backend Integration:

* PHP REST API
* JWT Authentication

Database:

* MySQL

Weather:

* OpenWeatherMap API

Deployment:

* Android APK
* Android AAB
* Flutter Web Build

---

## User Roles

### Admin

Full Access

### Farmer

Control and Monitoring

### Technician

Maintenance Access

---

## Authentication

Features:

* Login
* Logout
* JWT Authentication
* Session Management
* Secure Storage

Screens:

* Splash Screen
* Login Screen
* Forgot Password

---

## Dashboard

Display:

Current Weather

Temperature

Humidity

Rain Probability

Farm Status

Water Level

Bore Pump Status

Well Pump Status

Flow Rate

Last Sync Time

---

## Live Monitoring

Display:

Zone 1 Moisture

Zone 2 Moisture

Zone 3 Moisture

Zone 4 Moisture

Display values as:

* Percentage
* Gauge
* Status Color

Status Colors:

Green = Healthy

Yellow = Warning

Red = Critical

Auto Refresh:

Every 10 Seconds

---

## Irrigation Control

Manual Controls:

Bore Pump

Well Pump

Zone 1

Zone 2

Zone 3

Zone 4

Actions:

Start

Stop

Emergency Stop

Confirmation Dialog Required

---

## Schedule Management

Create Schedule

Fields:

* Zone
* Water Source
* Start Time
* End Time
* Repeat Daily
* Repeat Weekly

View:

* Calendar View
* List View

Edit Schedule

Delete Schedule

---

## Alerts Module

Display:

Low Moisture

Low Water Level

Motor Failure

Sensor Failure

No Water Flow

Weather Warning

Alert Severity:

Critical

Warning

Information

---

## Analytics Module

Charts:

Moisture Trend

Water Usage

Pump Runtime

Rainfall History

Daily Report

Weekly Report

Monthly Report

Use:

fl_chart

---

## Farm Layout Screen

Display Farm Layout

Components:

Borewell

Open Well

Zone 1

Zone 2

Zone 3

Zone 4

Color Coding:

Green

Yellow

Red

Support future GIS integration.

---

## Automation Screen

Display:

Automation Status

Current Rules

Examples:

IF Moisture < Threshold

THEN Start Irrigation

IF Rain Probability > 70

THEN Skip Irrigation

IF Water Level < 20%

THEN Stop Pumps

Allow Enable/Disable Rules.

---

## Notifications

Push Notifications

Trigger:

Pump Started

Pump Stopped

Low Moisture

Low Water

Weather Alert

Sensor Failure

---

## Offline Support

Store:

Last Sensor Data

Schedules

Farm Details

Sync automatically when internet returns.

---

## Settings

Farm Information

Weather API Settings

Threshold Settings

Profile Settings

Theme Settings

Dark Mode

Light Mode

---

## UI Requirements

Agriculture Theme

Primary Color:

Green

Secondary Color:

Blue

Requirements:

Responsive Layout

Mobile First

Tablet Support

Desktop Support

Web Dashboard Support

Accessibility Friendly

Material 3 Design

---

## Architecture

Use Clean Architecture

Layers:

Presentation

Application

Domain

Data

Repository Pattern

Dependency Injection

Provider State Management

---

## Deliverables

Complete Flutter Source Code

Android Build

Flutter Web Build

API Integration Layer

Reusable Components

Documentation

Deployment Guide

Testing Guide

Production Ready Code