import { Component } from '@angular/core';
import { environment } from '../environment';

@Component({
  selector: 'app-root',
  template: `
    <div class="container">
      <h1>Angular Environment Variables Demo</h1>
      <p>Current Configuration: {{ currentConfiguration }}</p>
      <p>Current API Key: {{ currentApiKey }}</p>
    </div>
  `,
  styleUrl: './app.component.css',
})
export class AppComponent {
  title = 'ng-env-docker-demo';
  currentApiKey = environment.apiKey;
  currentConfiguration = environment.configuration;
}
