# Background Rendering using Delphi

This small project shows how to stop the GUI freezing up when a processor-intensive image is rendered as a print preview. In this case the user selects the color from the ColorPicker. The rendering is done is a TThread and uses a "Sleep" statement to simulate the rendering delay. Once complete the image is transfered to the paintbox.
