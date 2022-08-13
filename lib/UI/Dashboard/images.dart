class Categories {
  String text;
  String image;
  Categories({
    required this.text,
    required this.image,
  });
}

const images = [
  'https://images.pexels.com/photos/819087/pexels-photo-819087.jpeg?auto=compress&cs=tinysrgb&w=600',
  'https://images.pexels.com/photos/1464213/pexels-photo-1464213.jpeg?auto=compress&cs=tinysrgb&w=600',
  'https://images.pexels.com/photos/159888/pexels-photo-159888.jpeg?auto=compress&cs=tinysrgb&w=600',
  'https://images.pexels.com/photos/3862632/pexels-photo-3862632.jpeg?auto=compress&cs=tinysrgb&w=600',
  'https://images.pexels.com/photos/1319854/pexels-photo-1319854.jpeg?auto=compress&cs=tinysrgb&w=600',
  'https://images.pexels.com/photos/9735563/pexels-photo-9735563.jpeg?auto=compress&cs=tinysrgb&w=600',
  'https://images.pexels.com/photos/2263436/pexels-photo-2263436.jpeg?auto=compress&cs=tinysrgb&w=600',
  'https://images.pexels.com/photos/2280571/pexels-photo-2280571.jpeg?auto=compress&cs=tinysrgb&w=600',
  'https://images.pexels.com/photos/6129507/pexels-photo-6129507.jpeg?auto=compress&cs=tinysrgb&w=600',
  'https://images.pexels.com/photos/280222/pexels-photo-280222.jpeg?auto=compress&cs=tinysrgb&w=600',

];
const cats = [
  'world',
  'politics',
  'business',
  'technology',
  'literature',
  'sports',
  'entertainment',
  'science',
  'health',
  'lifestyle',
];

getCategories(){
  List<Categories> categories = [];
  for(int i = 0; i < cats.length; i++){
    categories.add(Categories(
      text: cats[i],
      image: images[i],
    ));
  }
  return categories;
}