
AboutPage <- '<!DOCTYPE html>
<html lang="en">
<head>
<title>Urban Insights</title>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">
<link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Lato">
<link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Montserrat">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
<style>
body,h1,h2,h3,h4,h5,h6 {font-family: "Lato", sans-serif}
.w3-bar,h1,button {font-family: "Montserrat", sans-serif}
.fa-globe,.fa-microchip {font-size:200px}
</style>
</head>
<body>

<!-- Navbar -->
<div class="w3-top">
  <div class="w3-bar w3-gray w3-card w3-left-align w3-large">
    <a class="w3-bar-item w3-button w3-hide-medium w3-hide-large w3-right w3-padding-large w3-hover-white w3-large w3-gray" href="javascript:void(0);" onclick="myFunction()" title="Toggle Navigation Menu"><i class="fa fa-bars"></i></a>
    <a href="#" class="w3-bar-item w3-button w3-padding-large w3-white">Home</a>
    <a href="#" class="w3-bar-item w3-button w3-hide-small w3-padding-large w3-hover-white">Link 1</a>
    <a href="#" class="w3-bar-item w3-button w3-hide-small w3-padding-large w3-hover-white">Link 2</a>
    <a href="#" class="w3-bar-item w3-button w3-hide-small w3-padding-large w3-hover-white">Link 3</a>
    <a href="#" class="w3-bar-item w3-button w3-hide-small w3-padding-large w3-hover-white">Link 4</a>
  </div>

  <!-- Navbar on small screens -->
  <div id="navDemo" class="w3-bar-block w3-white w3-hide w3-hide-large w3-hide-medium w3-large">
    <a href="#" class="w3-bar-item w3-button w3-padding-large">Link 1</a>
    <a href="#" class="w3-bar-item w3-button w3-padding-large">Link 2</a>
    <a href="#" class="w3-bar-item w3-button w3-padding-large">Link 3</a>
    <a href="#" class="w3-bar-item w3-button w3-padding-large">Link 4</a>
  </div>
</div>

<!-- Header -->
<header class="w3-container w3-gray w3-center" style="padding:128px 16px">
  <h1 class="w3-margin w3-jumbo">Urban Insights</h1>
  <p class="w3-xlarge">Making better decisions, one pixel at a time!</p>
  <button class="w3-button w3-gray w3-padding-large w3-large w3-margin-top">A W210 Capstone Project</button>
</header>

<!-- First Grid -->
<div class="w3-row-padding w3-padding-64 w3-container">
  <div class="w3-content">
    <div class="w3-twothird">
      <h1>Our Technology</h1>
      <h5 class="w3-padding-32">Our mission is to identify irrigated vegetation including lawns and trees along with other landscapes including water, soil, and impervious surfaces. Using geographical data, aerial imagery, and advanced AI and ML techniques, the primary objective is to provide insights drive policies and plans aimed at reducing water usage with minimal adverse effects on urban micro climate and accounting for median household income in the process.</h5>

      <p class="w3-text-grey">Our dataset is accessed via the Google Earth Engine API, comprising of aerial imagery. We have used the image data from National Agricultural Imagery set. It consists of red, green, blue and near infrared bands. Using these 4 bands, we performed transformations and manipulations to access additional characteristics used as features in our model. Combining this with our few other datasets such as US Census Data, Land Surface Temperature and Emissivity Data.

Our model focuses on the County of Los Angeles. With the variability in terrain types, socioeconomic distribution and overall diversity, LA serves as a perfect study area.

We have trained our data on Los Angeles county in California, USA.</p>
    </div>

    <div class="w3-third w3-center">
      <i class="fa fa-globe w3-padding-64 w3-text-gray"></i>
    </div>
  </div>
</div>

<!-- Second Grid -->
<div class="w3-row-padding w3-light-grey w3-padding-64 w3-container">
  <div class="w3-content">
    <div class="w3-third w3-center">
      <i class="fa fa-microchip w3-padding-64 w3-text-gray w3-margin-right"></i>
    </div>

    <div class="w3-twothird">
      <h1>Use Cases</h1>
      <h5 class="w3-padding-32">Urban Insights uses Google Earth Engine API and Tensor Flow models.</h5>

      <p class="w3-text-grey">Our final model is an ensemble of two neural network sub-models, that takes the most confident estimate, or highest probability class, among the sub-models during classification. A representation of the ensemble model architecture is shown on the right, and the hyperparameters are shown on left. The two neural network sub-models share the same architecture and were trained using the same hyperparameters. Each model is a 3 layer model, with a dropout layer between each hidden layer. Each hidden layer has 32 nodes and the activation functions are ReLU functions. The difference between the two models is that the first model was trained on a single water class, whereas the second model was trained on additional data for an additional water class, where water was separated into pool and lake classes. When the highest probabilities are taken for each sub-model, these classes are mapped back as a single water class for classification.

The separation of these classes allowed the second model, and consequently our ensemble model, to perform better overall on water, given the variance in NDVI values for different types of water.</p>
    </div>
  </div>
</div>

<div class="w3-container w3-gray w3-center w3-opacity w3-padding-64">
    <h1 class="w3-margin w3-xlarge"><b>University of California, Berkeley</b></h1>
        <h1 class="w3-margin w3-xlarge">School of Information</h1>
        <h1 class="w3-margin w3-xlarge">Master of Information and Data Science</h1>
</div>

<!-- Footer -->
<footer class="w3-container w3-padding-64 w3-center w3-opacity">  
  <div class="w3-xlarge w3-padding-32">
    <i class="fa fa-facebook-official w3-hover-opacity"></i>
    <i class="fa fa-instagram w3-hover-opacity"></i>
    <i class="fa fa-snapchat w3-hover-opacity"></i>
    <i class="fa fa-pinterest-p w3-hover-opacity"></i>
    <i class="fa fa-twitter w3-hover-opacity"></i>
    <i class="fa fa-linkedin w3-hover-opacity"></i>
 </div>
 <p>Diana Chacon / Jorge Dayer / Vaishali Khandewal / Sudhitry Mondal / Carlos Ortiz / Hassan Saad / Sam Temlock</a></p>
</footer>

<script>
// Used to toggle the menu on small screens when clicking on the menu button
function myFunction() {
  var x = document.getElementById("navDemo");
  if (x.className.indexOf("w3-show") == -1) {
    x.className += " w3-show";
  } else { 
    x.className = x.className.replace(" w3-show", "");
  }
}
</script>

</body>
</html>
'