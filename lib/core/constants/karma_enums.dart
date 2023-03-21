enum Karma {
  comment(1),
  textPost(3),
  imagePost(5),
  awardPost(5),
  deletePost(-2);

  final int karma;
  const Karma(this.karma);
}
