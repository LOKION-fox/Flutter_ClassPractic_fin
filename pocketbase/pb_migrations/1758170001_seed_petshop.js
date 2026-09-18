// Seed data copied from the project's former mock-server.js.
// Test application accounts:
// admin / admin123
// manager / manager123
// customer / customer123

migrate((app) => {
  function createRecord(collectionName, data) {
    const collection = app.findCollectionByNameOrId(collectionName)
    const record = new Record(collection)
    for (const key in data) {
      record.set(key, data[key])
    }
    app.save(record)
    return record
  }

  function createUser(username, fullName, role, password) {
    const collection = app.findCollectionByNameOrId('users')
    const record = new Record(collection)
    record.set('username', username)
    record.set('fullName', fullName)
    record.set('role', role)
    record.setVerified(true)
    record.setPassword(password)
    app.save(record)
    return record
  }

  const admin = createUser('admin', 'Администратор', 'admin', 'admin123')
  const manager = createUser('manager', 'Менеджер', 'manager', 'manager123')
  const customerUser = createUser('customer', 'Покупатель', 'customer', 'customer123')

  const categories = [
  {
    "name": "Корм",
    "kind": "product",
    "description": "Корма для домашних животных"
  },
  {
    "name": "Игрушки",
    "kind": "product",
    "description": "Игрушки для животных"
  },
  {
    "name": "Аксессуары",
    "kind": "product",
    "description": "Ошейники, поводки, миски и переноски"
  },
  {
    "name": "Гигиена",
    "kind": "product",
    "description": "Средства ухода и гигиены"
  },
  {
    "name": "Аквариумистика",
    "kind": "product",
    "description": "Товары для аквариумов"
  },
  {
    "name": "Веттовары",
    "kind": "both",
    "description": "Средства для здоровья животных"
  },
  {
    "name": "Кошки",
    "kind": "animal",
    "description": "Кошки различных пород"
  },
  {
    "name": "Собаки",
    "kind": "animal",
    "description": "Собаки различных пород"
  },
  {
    "name": "Грызуны",
    "kind": "animal",
    "description": "Хомяки и другие грызуны"
  },
  {
    "name": "Птицы",
    "kind": "animal",
    "description": "Домашние декоративные птицы"
  },
  {
    "name": "Кролики",
    "kind": "animal",
    "description": "Декоративные кролики"
  },
  {
    "name": "Морские свинки",
    "kind": "animal",
    "description": "Домашние морские свинки"
  },
  {
    "name": "Террариумистика",
    "kind": "product",
    "description": "Товары для террариумов"
  }
]
  const categoryIds = {}
  categories.forEach((item, index) => {
    const record = createRecord('categories', item)
    categoryIds[index + 1] = record.id
  })

  const suppliers = [
  {
    "name": "ЗооОпт",
    "country": "Россия",
    "email": "opt@zoopt.ru",
    "allowedCategoryIds": [
      1,
      2,
      3,
      4,
      6
    ]
  },
  {
    "name": "PetFood Distribution",
    "country": "Россия",
    "email": "food@petfood.ru",
    "allowedCategoryIds": [
      1,
      6
    ]
  },
  {
    "name": "AquaWorld",
    "country": "Германия",
    "email": "info@aquaworld.de",
    "allowedCategoryIds": [
      5
    ]
  },
  {
    "name": "Animal House",
    "country": "Россия",
    "email": "animals@house.ru",
    "allowedCategoryIds": [
      7,
      8,
      9,
      11,
      12
    ]
  },
  {
    "name": "BirdLand",
    "country": "Польша",
    "email": "birds@birdland.pl",
    "allowedCategoryIds": [
      10
    ]
  },
  {
    "name": "PetMarket Север",
    "country": "Россия",
    "email": "north@petmarket.ru",
    "allowedCategoryIds": [
      1,
      2,
      3,
      4,
      6,
      7,
      8,
      9,
      10,
      11,
      12
    ]
  },
  {
    "name": "ВетСнаб",
    "country": "Россия",
    "email": "vet@vetsnab.ru",
    "allowedCategoryIds": [
      6
    ]
  },
  {
    "name": "Happy Pets",
    "country": "Беларусь",
    "email": "shop@happypets.by",
    "allowedCategoryIds": [
      2,
      3,
      4,
      7,
      8
    ]
  },
  {
    "name": "ГрызунОПТ",
    "country": "Россия",
    "email": "rodent@opt.ru",
    "allowedCategoryIds": [
      9,
      11,
      12
    ]
  },
  {
    "name": "Птичий мир",
    "country": "Россия",
    "email": "bird@world.ru",
    "allowedCategoryIds": [
      10
    ]
  },
  {
    "name": "Premium Food",
    "country": "Франция",
    "email": "food@premium.fr",
    "allowedCategoryIds": [
      1
    ]
  },
  {
    "name": "Terra Zoo",
    "country": "Россия",
    "email": "terra@zoo.ru",
    "allowedCategoryIds": [
      13
    ]
  }
]
  const supplierIds = {}
  suppliers.forEach((item, index) => {
    const record = createRecord('suppliers', {
      name: item.name,
      country: item.country,
      email: item.email,
      allowedCategoryIds: item.allowedCategoryIds.map((id) => categoryIds[id]),
    })
    supplierIds[index + 1] = record.id
  })

  const products = [
  {
    "name": "Royal Canin Sterilised",
    "article": "RC-001",
    "brand": "Royal Canin",
    "price": 1890,
    "stock": 25,
    "supplierId": 2,
    "categoryIds": [
      1
    ],
    "description": "Сухой корм для стерилизованных кошек"
  },
  {
    "name": "Royal Canin Mini Adult",
    "article": "RC-002",
    "brand": "Royal Canin",
    "price": 2250,
    "stock": 18,
    "supplierId": 2,
    "categoryIds": [
      1
    ],
    "description": "Корм для взрослых собак мелких пород"
  },
  {
    "name": "Purina One Cat",
    "article": "PU-001",
    "brand": "Purina",
    "price": 1230,
    "stock": 31,
    "supplierId": 1,
    "categoryIds": [
      1
    ],
    "description": "Сухой корм для взрослых кошек"
  },
  {
    "name": "Purina Dog Chow",
    "article": "PU-002",
    "brand": "Purina",
    "price": 1780,
    "stock": 21,
    "supplierId": 1,
    "categoryIds": [
      1
    ],
    "description": "Полнорационный корм для собак"
  },
  {
    "name": "Brit Premium Cat",
    "article": "BR-001",
    "brand": "Brit",
    "price": 1460,
    "stock": 17,
    "supplierId": 1,
    "categoryIds": [
      1
    ],
    "description": "Корм для взрослых домашних кошек"
  },
  {
    "name": "Hill's Science Plan",
    "article": "HI-001",
    "brand": "Hill's",
    "price": 2490,
    "stock": 13,
    "supplierId": 11,
    "categoryIds": [
      1
    ],
    "description": "Сбалансированный корм для кошек"
  },
  {
    "name": "Мяч Trixie",
    "article": "TR-001",
    "brand": "Trixie",
    "price": 450,
    "stock": 45,
    "supplierId": 1,
    "categoryIds": [
      2
    ],
    "description": "Резиновый мяч для собак"
  },
  {
    "name": "Игрушка-мышь Trixie",
    "article": "TR-002",
    "brand": "Trixie",
    "price": 320,
    "stock": 52,
    "supplierId": 1,
    "categoryIds": [
      2
    ],
    "description": "Игрушка для кошек"
  },
  {
    "name": "Канат для собак",
    "article": "TR-003",
    "brand": "Trixie",
    "price": 680,
    "stock": 19,
    "supplierId": 1,
    "categoryIds": [
      2
    ],
    "description": "Канат для активных собак"
  },
  {
    "name": "Поводок Flexi Classic",
    "article": "FL-001",
    "brand": "Flexi",
    "price": 1990,
    "stock": 14,
    "supplierId": 1,
    "categoryIds": [
      3
    ],
    "description": "Рулетка-поводок длиной 5 метров"
  },
  {
    "name": "Ошейник Trixie",
    "article": "TR-004",
    "brand": "Trixie",
    "price": 840,
    "stock": 28,
    "supplierId": 1,
    "categoryIds": [
      3
    ],
    "description": "Регулируемый ошейник"
  },
  {
    "name": "Переноска для кошек",
    "article": "TR-005",
    "brand": "Trixie",
    "price": 2990,
    "stock": 9,
    "supplierId": 1,
    "categoryIds": [
      3
    ],
    "description": "Пластиковая переноска"
  },
  {
    "name": "Шампунь Beaphar",
    "article": "BE-001",
    "brand": "Beaphar",
    "price": 950,
    "stock": 22,
    "supplierId": 1,
    "categoryIds": [
      4
    ],
    "description": "Мягкий шампунь для собак"
  },
  {
    "name": "Средство для шерсти",
    "article": "BE-002",
    "brand": "Beaphar",
    "price": 1130,
    "stock": 16,
    "supplierId": 1,
    "categoryIds": [
      4
    ],
    "description": "Средство ухода за шерстью"
  },
  {
    "name": "Щётка Trixie",
    "article": "TR-006",
    "brand": "Trixie",
    "price": 790,
    "stock": 30,
    "supplierId": 1,
    "categoryIds": [
      4
    ],
    "description": "Щётка для вычёсывания"
  },
  {
    "name": "JBL NovoBel",
    "article": "JBL-001",
    "brand": "JBL",
    "price": 640,
    "stock": 35,
    "supplierId": 3,
    "categoryIds": [
      5
    ],
    "description": "Корм для аквариумных рыб"
  },
  {
    "name": "JBL FilterStart",
    "article": "JBL-002",
    "brand": "JBL",
    "price": 860,
    "stock": 11,
    "supplierId": 3,
    "categoryIds": [
      5
    ],
    "description": "Средство запуска фильтра"
  },
  {
    "name": "JBL AquaBasis",
    "article": "JBL-003",
    "brand": "JBL",
    "price": 1520,
    "stock": 10,
    "supplierId": 3,
    "categoryIds": [
      5
    ],
    "description": "Грунт для аквариума"
  },
  {
    "name": "Beaphar Vitamin B",
    "article": "BE-003",
    "brand": "Beaphar",
    "price": 1070,
    "stock": 24,
    "supplierId": 7,
    "categoryIds": [
      6
    ],
    "description": "Витаминная добавка"
  },
  {
    "name": "Beaphar Dental Kit",
    "article": "BE-004",
    "brand": "Beaphar",
    "price": 1390,
    "stock": 15,
    "supplierId": 7,
    "categoryIds": [
      6
    ],
    "description": "Набор для ухода за зубами"
  },
  {
    "name": "Brit Care Dog",
    "article": "BR-002",
    "brand": "Brit",
    "price": 2040,
    "stock": 26,
    "supplierId": 1,
    "categoryIds": [
      1
    ],
    "description": "Гипоаллергенный корм"
  },
  {
    "name": "Миска Trixie",
    "article": "TR-007",
    "brand": "Trixie",
    "price": 590,
    "stock": 39,
    "supplierId": 1,
    "categoryIds": [
      3
    ],
    "description": "Металлическая миска"
  },
  {
    "name": "Flexi New Comfort",
    "article": "FL-002",
    "brand": "Flexi",
    "price": 2690,
    "stock": 12,
    "supplierId": 1,
    "categoryIds": [
      3
    ],
    "description": "Рулетка для прогулок"
  },
  {
    "name": "Purina Pro Plan",
    "article": "PU-003",
    "brand": "Purina",
    "price": 2850,
    "stock": 20,
    "supplierId": 2,
    "categoryIds": [
      1
    ],
    "description": "Премиальный корм для собак"
  }
]
  const productIdsByArticle = {}
  products.forEach((item) => {
    const record = createRecord('products', {
      name: item.name,
      article: item.article,
      brand: item.brand,
      price: item.price,
      stock: item.stock,
      supplierId: supplierIds[item.supplierId],
      categoryIds: item.categoryIds.map((id) => categoryIds[id]),
      description: item.description,
    })
    productIdsByArticle[item.article] = record.id
  })

  const animals = [
  {
    "name": "Барсик",
    "species": "Кошка",
    "breed": "Британская короткошёрстная",
    "ageMonths": 5,
    "sex": "Самец",
    "country": "Россия",
    "price": 35000,
    "supplierId": 4,
    "categoryIds": [
      7
    ],
    "description": "Спокойный британский котёнок"
  },
  {
    "name": "Луна",
    "species": "Кошка",
    "breed": "Мейн-кун",
    "ageMonths": 6,
    "sex": "Самка",
    "country": "Россия",
    "price": 48000,
    "supplierId": 4,
    "categoryIds": [
      7
    ],
    "description": "Активная и дружелюбная кошка"
  },
  {
    "name": "Рекс",
    "species": "Собака",
    "breed": "Немецкая овчарка",
    "ageMonths": 8,
    "sex": "Самец",
    "country": "Германия",
    "price": 70000,
    "supplierId": 8,
    "categoryIds": [
      8
    ],
    "description": "Умный и активный щенок"
  },
  {
    "name": "Белла",
    "species": "Собака",
    "breed": "Лабрадор",
    "ageMonths": 7,
    "sex": "Самка",
    "country": "Россия",
    "price": 65000,
    "supplierId": 4,
    "categoryIds": [
      8
    ],
    "description": "Дружелюбный щенок"
  },
  {
    "name": "Хома",
    "species": "Хомяк",
    "breed": "Сирийский",
    "ageMonths": 3,
    "sex": "Самец",
    "country": "Россия",
    "price": 2500,
    "supplierId": 9,
    "categoryIds": [
      9
    ],
    "description": "Молодой сирийский хомяк"
  },
  {
    "name": "Кеша",
    "species": "Попугай",
    "breed": "Волнистый",
    "ageMonths": 5,
    "sex": "Самец",
    "country": "Россия",
    "price": 4500,
    "supplierId": 5,
    "categoryIds": [
      10
    ],
    "description": "Активный волнистый попугай"
  },
  {
    "name": "Пушинка",
    "species": "Кролик",
    "breed": "Карликовый",
    "ageMonths": 4,
    "sex": "Самка",
    "country": "Россия",
    "price": 7000,
    "supplierId": 9,
    "categoryIds": [
      11
    ],
    "description": "Белый декоративный кролик"
  },
  {
    "name": "Тиша",
    "species": "Морская свинка",
    "breed": "Американская",
    "ageMonths": 5,
    "sex": "Самец",
    "country": "Россия",
    "price": 3500,
    "supplierId": 9,
    "categoryIds": [
      12
    ],
    "description": "Спокойная морская свинка"
  },
  {
    "name": "Мия",
    "species": "Кошка",
    "breed": "Шотландская вислоухая",
    "ageMonths": 4,
    "sex": "Самка",
    "country": "Россия",
    "price": 39000,
    "supplierId": 4,
    "categoryIds": [
      7
    ],
    "description": "Ласковая молодая кошка"
  },
  {
    "name": "Рио",
    "species": "Попугай",
    "breed": "Корелла",
    "ageMonths": 9,
    "sex": "Самец",
    "country": "Россия",
    "price": 12000,
    "supplierId": 10,
    "categoryIds": [
      10
    ],
    "description": "Ручной попугай корелла"
  },
  {
    "name": "Том",
    "species": "Кошка",
    "breed": "Сибирская",
    "ageMonths": 8,
    "sex": "Самец",
    "country": "Россия",
    "price": 32000,
    "supplierId": 6,
    "categoryIds": [
      7
    ],
    "description": "Спокойный сибирский кот"
  },
  {
    "name": "Джесси",
    "species": "Собака",
    "breed": "Корги",
    "ageMonths": 6,
    "sex": "Самка",
    "country": "Россия",
    "price": 85000,
    "supplierId": 6,
    "categoryIds": [
      8
    ],
    "description": "Активный щенок корги"
  }
]
  const animalIdsByName = {}
  animals.forEach((item) => {
    const record = createRecord('animals', {
      name: item.name,
      species: item.species,
      breed: item.breed,
      ageMonths: item.ageMonths,
      sex: item.sex,
      country: item.country,
      price: item.price,
      supplierId: supplierIds[item.supplierId],
      categoryIds: item.categoryIds.map((id) => categoryIds[id]),
      description: item.description,
    })
    animalIdsByName[item.name] = record.id
  })

  const customers = [
  {
    "firstName": "Иван",
    "lastName": "Петров",
    "email": "ivan@example.ru",
    "phone": "+79990000001",
    "loyaltyCard": {
      "number": "CARD-001",
      "level": "Silver",
      "points": 120,
      "issuedAt": "2026-01-10 00:00:00.000Z"
    }
  },
  {
    "firstName": "Анна",
    "lastName": "Смирнова",
    "email": "anna@example.ru",
    "phone": "+79990000002",
    "loyaltyCard": {
      "number": "CARD-002",
      "level": "Gold",
      "points": 840,
      "issuedAt": "2026-01-11 00:00:00.000Z"
    }
  },
  {
    "firstName": "Максим",
    "lastName": "Орлов",
    "email": "max@example.ru",
    "phone": "+79990000003",
    "loyaltyCard": {
      "number": "CARD-003",
      "level": "Silver",
      "points": 90,
      "issuedAt": "2026-01-12 00:00:00.000Z"
    }
  },
  {
    "firstName": "Елена",
    "lastName": "Кузнецова",
    "email": "elena@example.ru",
    "phone": "+79990000004",
    "loyaltyCard": {
      "number": "CARD-004",
      "level": "Platinum",
      "points": 2400,
      "issuedAt": "2026-01-13 00:00:00.000Z"
    }
  },
  {
    "firstName": "Алексей",
    "lastName": "Волков",
    "email": "alex@example.ru",
    "phone": "+79990000005",
    "loyaltyCard": {
      "number": "CARD-005",
      "level": "Gold",
      "points": 730,
      "issuedAt": "2026-01-14 00:00:00.000Z"
    }
  },
  {
    "firstName": "Мария",
    "lastName": "Морозова",
    "email": "maria@example.ru",
    "phone": "+79990000006",
    "loyaltyCard": {
      "number": "CARD-006",
      "level": "Silver",
      "points": 210,
      "issuedAt": "2026-01-15 00:00:00.000Z"
    }
  },
  {
    "firstName": "Олег",
    "lastName": "Соколов",
    "email": "oleg@example.ru",
    "phone": "+79990000007",
    "loyaltyCard": {
      "number": "CARD-007",
      "level": "Gold",
      "points": 920,
      "issuedAt": "2026-01-16 00:00:00.000Z"
    }
  },
  {
    "firstName": "Дарья",
    "lastName": "Лебедева",
    "email": "daria@example.ru",
    "phone": "+79990000008",
    "loyaltyCard": {
      "number": "CARD-008",
      "level": "Platinum",
      "points": 3100,
      "issuedAt": "2026-01-17 00:00:00.000Z"
    }
  },
  {
    "firstName": "Роман",
    "lastName": "Попов",
    "email": "roman@example.ru",
    "phone": "+79990000009",
    "loyaltyCard": {
      "number": "CARD-009",
      "level": "Silver",
      "points": 160,
      "issuedAt": "2026-01-18 00:00:00.000Z"
    }
  },
  {
    "firstName": "Светлана",
    "lastName": "Новикова",
    "email": "sveta@example.ru",
    "phone": "+79990000010",
    "loyaltyCard": {
      "number": "CARD-010",
      "level": "Gold",
      "points": 660,
      "issuedAt": "2026-01-19 00:00:00.000Z"
    }
  },
  {
    "firstName": "Никита",
    "lastName": "Фёдоров",
    "email": "nikita@example.ru",
    "phone": "+79990000011",
    "loyaltyCard": {
      "number": "CARD-011",
      "level": "Silver",
      "points": 250,
      "issuedAt": "2026-01-20 00:00:00.000Z"
    }
  },
  {
    "firstName": "Ольга",
    "lastName": "Васильева",
    "email": "olga@example.ru",
    "phone": "+79990000012",
    "loyaltyCard": {
      "number": "CARD-012",
      "level": "Gold",
      "points": 1050,
      "issuedAt": "2026-01-21 00:00:00.000Z"
    }
  }
]
  const customerIds = {}
  customers.forEach((item, index) => {
    const customer = createRecord('customers', {
      firstName: item.firstName,
      lastName: item.lastName,
      email: item.email,
      phone: item.phone,
      userId: index === 0 ? customerUser.id : '',
    })
    customerIds[index + 1] = customer.id

    createRecord('loyalty_cards', {
      customerId: customer.id,
      number: item.loyaltyCard.number,
      level: item.loyaltyCard.level,
      points: item.loyaltyCard.points,
      issuedAt: item.loyaltyCard.issuedAt,
    })
  })

  // A couple of linked demo orders for the two new project entities.
  const order1 = createRecord('orders', {
    orderNumber: 'ORD-2026-001',
    customerId: customerIds[1],
    createdById: manager.id,
    status: 'paid',
    total: 2530,
    notes: 'Тестовый заказ покупателя',
    orderedAt: '2026-09-18 09:00:00.000Z',
  })
  createRecord('order_items', {
    orderId: order1.id,
    itemType: 'product',
    productId: productIdsByArticle['RC-001'],
    animalId: '',
    quantity: 1,
    unitPrice: 1890,
    lineTotal: 1890,
  })
  createRecord('order_items', {
    orderId: order1.id,
    itemType: 'product',
    productId: productIdsByArticle['TR-002'],
    animalId: '',
    quantity: 2,
    unitPrice: 320,
    lineTotal: 640,
  })

  const order2 = createRecord('orders', {
    orderNumber: 'ORD-2026-002',
    customerId: customerIds[2],
    createdById: admin.id,
    status: 'processing',
    total: 48000,
    notes: 'Заказ животного',
    orderedAt: '2026-09-18 09:30:00.000Z',
  })
  createRecord('order_items', {
    orderId: order2.id,
    itemType: 'animal',
    productId: '',
    animalId: animalIdsByName['Луна'],
    quantity: 1,
    unitPrice: 48000,
    lineTotal: 48000,
  })
}, (app) => {
  // This migration is intended for a fresh educational database,
  // so rollback removes the seeded records from all project collections.
  const names = [
    'order_items',
    'orders',
    'loyalty_cards',
    'customers',
    'animals',
    'products',
    'suppliers',
    'categories',
    'users',
  ]

  for (const name of names) {
    try {
      const records = app.findAllRecords(name)
      for (const record of records) {
        app.delete(record)
      }
    } catch (_) {}
  }
})
