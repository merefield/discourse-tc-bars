import Component from "@glimmer/component";
import { htmlSafe } from "@ember/template";

export default class BarsCustomHtmlComponent extends Component {
  get safeHtmlContent() {
    return htmlSafe(this.args.params.content);
  }

  <template>
    {{this.safeHtmlContent}}
  </template>
}
