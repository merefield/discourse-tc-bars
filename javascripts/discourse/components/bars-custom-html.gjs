import Component from "@glimmer/component";
import { trustHTML } from "@ember/template";

export default class BarsCustomHtmlComponent extends Component {
  get safeHtmlContent() {
    return trustHTML(this.args.params.content);
  }

  <template>{{this.safeHtmlContent}}</template>
}
