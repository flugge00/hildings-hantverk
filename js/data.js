/* ============================================================
   Hildings Hantverk — innehåll (content)
   ------------------------------------------------------------
   Här ligger allt innehåll som ändras ofta samlat på ETT ställe.
   Vill du lägga till, ta bort eller ändra en produkt eller bild –
   gör det bara i listorna nedan. Ingen annan fil behöver röras.

   • Produktbilder ligger i:  images/
   • Galleribilder ligger i:  images/gallery/
   ============================================================ */

window.SITE_DATA = {
  /* Katalog-sidan. Lägg till en ny produkt genom att kopiera ett block.
     "desc" visas i popup-rutan när man klickar på en produkt. Lämna gärna
     tomt ("") om du inte vill ha någon beskrivning – då göms texten. */
  products: [
    {
      name: "Hög Femma vit", price: "325kr", img: "images/5hogProduct.jpg",
      desc: "Handdoppad ljuskrona med fem höga, vita ljus. En reslig klassiker som ger ett stämningsfullt sken – perfekt för adventsbordet eller festkvällen."
    },
    {
      name: "Fyra grön", price: "250kr", img: "images/4gronProduct.jpg",
      desc: "Fyra ljus i dämpad grön ton, sammanfogade till en nätt krona. Handgjord och gjord för att lysa upp både vardag och helg."
    },
    {
      name: "Låg Femma vit", price: "325kr", img: "images/5lagProduct.jpg",
      desc: "Femarmad krona i vitt med lägre höjd – samma karaktär som den höga, men i ett mer lågmält format."
    },
    {
      name: "Sexa grön", price: "500kr", img: "images/6gronProduct.jpg",
      desc: "Vår största krona med sex ljus i grönt. Ett rejält blickfång som sprider generöst med ljus."
    },
    {
      name: "Sockertoppar", price: "150kr", img: "images/sockertopparProduct.jpg",
      desc: "Koniska ljus formade som sockertoppar. Rustika och charmiga – fina både ensamma och i grupp."
    },
    {
      name: "Hög Fyra SickSack", price: "300kr", img: "images/sicksack4hogProduct.jpg",
      desc: "Fyra höga ljus i ett grafiskt sicksackmönster. Modern form möter handgjort hantverk."
    },
    {
      name: "Låg Fyra SickSack", price: "300kr", img: "images/sicksack4Product.jpg",
      desc: "Sicksackkronans lägre syskon – fyra ljus i ett lekfullt, geometriskt mönster."
    },
    {
      name: "Hög Femma SickSack", price: "450kr", img: "images/sicksack5Product.jpg",
      desc: "Fem höga ljus i en markant sicksackform. Ett arkitektoniskt uttryck som tar plats."
    },
    {
      name: "Snöbollar", price: "60kr", img: "images/snobollarProduct.jpg",
      desc: "Runda, vita ljus som små snöbollar. Söta att ställa i grupp för en vinterkänsla året om."
    },
    {
      name: "Spiror", price: "120kr", img: "images/spirorProduct.jpg",
      desc: "Smala, resliga spiror – enkla och stilrena ljus som passar i de flesta ljusstakar."
    }
  ],

  /* Bilder-sidan (galleriet). "alt" beskriver bilden för skärmläsare. */
  gallery: [
    { img: "images/gallery/ekenasBigMolly.jpg",          alt: "Molly på marknad i Ekenäs" },
    { img: "images/gallery/ekenasApples.jpg",            alt: "Ljus och äpplen" },
    { img: "images/gallery/ekenasCollection.jpg",        alt: "Samling av ljus" },
    { img: "images/gallery/ekenasCollectionSmall.jpg",   alt: "Mindre samling av ljus" },
    { img: "images/gallery/vadstenaCollectionMolly.jpg", alt: "Ljus i Vadstena" },
    { img: "images/gallery/rodFemma.jpg",                alt: "Röd femma" },
    { img: "images/gallery/vadstenaFonster.jpg",         alt: "Ljus i fönster, Vadstena" }
  ]
};
