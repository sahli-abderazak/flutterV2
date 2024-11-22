class UnbordingContent
{
  String image;
  String title;
  String description;

  UnbordingContent({required this.description, required this.image, required this.title});

}

List<UnbordingContent> contents =[UnbordingContent
  (description:'Pick your food from our menu\n        More than 35 times '
    ,image:"images/screen1.png",
  title: 'Select from Our\n      Best Menu  ',
),
  UnbordingContent (description:'You can Pay cash on delivery and\n       Card payment is available'
    ,image:"images/screen2.png",
    title: 'Easy and Online Payment',
  ),
  UnbordingContent (description:'Deliver Your Food at your\n                Doorstep'
    ,image:"images/screen3.png",
    title: 'Quick Delivery at Your Doorstep',
  ),

];