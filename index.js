import { MediaApp } from "./mediaApp.js"
import { Elm } from "./src/Main.elm"

(function() {
  const flags = {
    mainVideoUrl: "/assets/master.mp4",
    videoLength: 82,
    overlays: [
       {
         "interval": "1|4",
         "buttonText": "Click for Location",
         "overlay": {
           "text": "Filmed at the Orcas Center, Madrona Room on December 19, 2019"
          }
       },
       {
         "interval": "6|10",
         "buttonText": "Click for Link",
         "overlay": {
           "href": "https://www.orcas.dance",
           "text": "www.orcas.dance"
          }
       },
       {
         "interval": "12|18",
         "buttonText": "Click for Photo",
         "overlay": {
           "alt": "Dancer!",
           "src": "/assets/po1.jpg"
          }
       },
       {
         "interval": "22|30",
         "buttonText": "Click for Video",
         "overlay": {
           "url": "/assets/v01.mp4"
          }
       }
    ]
  }
  let elmApp = Elm.Main.init({
    node: document.getElementById("video"),
    flags: flags
  });

  elmApp.ports.outbound.subscribe(MediaApp.portHandler);
})()
