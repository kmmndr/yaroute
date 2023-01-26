// Entry point for the build script in your package.json
import {Turbo} from "@hotwired/turbo-rails"
import "./controllers"

Turbo.session.drive = false