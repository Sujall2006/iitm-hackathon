const appConfig = {
  admin: {
    phoneNumber: "1234567899",
    mailId: "tarunjaikishan1499@gmail.com",
    password: "admin@123",
  },
  operator: {
    password: "123456",
  },

  ports: [
    { name: "AC|AC Type-1", output: "50kW" },
    { name: "AC|AC Type-2", output: "50kW" },
    // { name: "AC|Bharat AC001", output: "50kW" },
    { name: "AC|AC Plug Point", output: "50kW" },

    { name: "DC|CCS-1", output: "50kW" },
    { name: "DC|CCS-2", output: "50kW" },
    // { name: "DC|Bharat DC001 GB/T", output: "50kW" },
    // { name: "DC|Tesla Charger", output: "50kW" },
    { name: "DC|CHAdeMO", output: "50kW" },
    { name: "DC|GB/T", output: "50kW" },
  ],

  states: [
    {
      "Tamil Nadu": ["Chennai", "Salem", "Coimbatore", "Trichy", "Madurai"],
      Karnataka: ["Bengaluru", "Mysore"],
    },
  ],

  showNearestCount: 5,
  alternativeMaxKm: 100000,
  showAlternativeCount: 2,
};

module.exports = { appConfig };
