// PetShop PocketBase schema
// Compatible with current PocketBase JavaScript migrations.

migrate((app) => {
  const catalogListRule = '@request.auth.id != "" && ((@request.auth.role = "customer" && deletedAt = "") || @request.auth.role = "manager" || @request.auth.role = "admin")'
  const managerOrAdmin = '@request.auth.role = "manager" || @request.auth.role = "admin"'
  const updateActiveOrAdmin = '@request.auth.role = "admin" || (@request.auth.role = "manager" && deletedAt = "")'
  const adminOnly = '@request.auth.role = "admin"'

  const timestamps = () => [
    { type: 'autodate', name: 'created', onCreate: true, onUpdate: false },
    { type: 'autodate', name: 'updated', onCreate: true, onUpdate: true },
  ]

  // 1. users (Auth collection)
  // PocketBase v0.23+ creates the default `users` auth collection automatically.
  // We extend that collection instead of creating another one.
  const users = app.findCollectionByNameOrId('users')

  users.listRule = adminOnly
  users.viewRule = 'id = @request.auth.id || @request.auth.role = "admin"'
  users.createRule = '(@request.auth.id = "" && @request.body.role = "customer") || @request.auth.role = "admin"'
  users.updateRule = '(id = @request.auth.id && @request.body.role:changed = false) || (@request.auth.role = "admin" && (id != @request.auth.id || @request.body.role:changed = false))'
  users.deleteRule = '@request.auth.role = "admin" && id != @request.auth.id'
  users.manageRule = adminOnly
  users.authRule = 'deletedAt = ""'
  users.passwordAuth = {
    enabled: true,
    identityFields: ['username'],
  }

  // Email is optional because the Flutter app authenticates by username.
  const emailField = users.fields.getByName('email')
  if (emailField) {
    emailField.required = false
  }

  // FieldsList.add replaces a same-name field or appends it when missing.
  users.fields.add(new TextField({
    name: 'username',
    required: true,
    min: 3,
    max: 40,
    pattern: '^[A-Za-z0-9_.-]+$',
    presentable: true,
  }))
  users.fields.add(new TextField({
    name: 'fullName',
    required: true,
    min: 2,
    max: 120,
    presentable: true,
  }))
  users.fields.add(new SelectField({
    name: 'role',
    required: true,
    maxSelect: 1,
    values: ['customer', 'manager', 'admin'],
  }))
  users.fields.add(new DateField({
    name: 'deletedAt',
  }))

  users.addIndex('idx_users_username', true, 'username', '')
  app.save(users)

  // 2. categories
  const categories = new Collection({
    type: 'base',
    name: 'categories',
    listRule: catalogListRule,
    viewRule: catalogListRule,
    createRule: managerOrAdmin,
    updateRule: updateActiveOrAdmin,
    deleteRule: adminOnly,
    fields: [
      { type: 'text', name: 'name', required: true, min: 2, max: 100, presentable: true },
      { type: 'select', name: 'kind', required: true, maxSelect: 1, values: ['product', 'animal', 'both'] },
      { type: 'text', name: 'description', max: 1000 },
      { type: 'date', name: 'deletedAt' },
      ...timestamps(),
    ],
    indexes: [
      'CREATE UNIQUE INDEX idx_categories_name ON categories (name)',
      'CREATE INDEX idx_categories_kind ON categories (kind)',
    ],
  })
  app.save(categories)

  // 3. suppliers
  const suppliers = new Collection({
    type: 'base',
    name: 'suppliers',
    listRule: catalogListRule,
    viewRule: catalogListRule,
    createRule: managerOrAdmin,
    updateRule: updateActiveOrAdmin,
    deleteRule: adminOnly,
    fields: [
      { type: 'text', name: 'name', required: true, min: 2, max: 120, presentable: true },
      { type: 'text', name: 'country', required: true, min: 2, max: 80 },
      { type: 'email', name: 'email', required: true },
      { type: 'relation', name: 'allowedCategoryIds', collectionId: categories.id, required: true, minSelect: 1, maxSelect: 50, cascadeDelete: false },
      { type: 'date', name: 'deletedAt' },
      ...timestamps(),
    ],
    indexes: [
      'CREATE INDEX idx_suppliers_name ON suppliers (name)',
      'CREATE INDEX idx_suppliers_country ON suppliers (country)',
    ],
  })
  app.save(suppliers)

  // 4. products
  const products = new Collection({
    type: 'base',
    name: 'products',
    listRule: catalogListRule,
    viewRule: catalogListRule,
    createRule: managerOrAdmin,
    updateRule: updateActiveOrAdmin,
    deleteRule: adminOnly,
    fields: [
      { type: 'text', name: 'name', required: true, min: 2, max: 160, presentable: true },
      { type: 'text', name: 'article', required: true, min: 2, max: 50 },
      { type: 'text', name: 'brand', required: true, min: 1, max: 100 },
      { type: 'number', name: 'price', required: true, min: 0.01 },
      { type: 'number', name: 'stock', onlyInt: true, min: 0 },
      { type: 'relation', name: 'supplierId', collectionId: suppliers.id, required: true, maxSelect: 1, cascadeDelete: false },
      { type: 'relation', name: 'categoryIds', collectionId: categories.id, required: true, minSelect: 1, maxSelect: 20, cascadeDelete: false },
      { type: 'text', name: 'description', max: 2000 },
      { type: 'date', name: 'deletedAt' },
      ...timestamps(),
    ],
    indexes: [
      'CREATE UNIQUE INDEX idx_products_article ON products (article)',
      'CREATE INDEX idx_products_name ON products (name)',
      'CREATE INDEX idx_products_brand ON products (brand)',
      'CREATE INDEX idx_products_price ON products (price)',
    ],
  })
  app.save(products)

  // 5. animals
  const animals = new Collection({
    type: 'base',
    name: 'animals',
    listRule: catalogListRule,
    viewRule: catalogListRule,
    createRule: managerOrAdmin,
    updateRule: updateActiveOrAdmin,
    deleteRule: adminOnly,
    fields: [
      { type: 'text', name: 'name', required: true, min: 1, max: 100, presentable: true },
      { type: 'text', name: 'species', required: true, min: 2, max: 80 },
      { type: 'text', name: 'breed', required: true, min: 2, max: 120 },
      { type: 'number', name: 'ageMonths', required: true, onlyInt: true, min: 1, max: 600 },
      { type: 'select', name: 'sex', required: true, maxSelect: 1, values: ['Самец', 'Самка'] },
      { type: 'text', name: 'country', required: true, min: 2, max: 80 },
      { type: 'number', name: 'price', required: true, min: 0.01 },
      { type: 'relation', name: 'supplierId', collectionId: suppliers.id, required: true, maxSelect: 1, cascadeDelete: false },
      { type: 'relation', name: 'categoryIds', collectionId: categories.id, required: true, minSelect: 1, maxSelect: 20, cascadeDelete: false },
      { type: 'text', name: 'description', max: 2000 },
      { type: 'date', name: 'deletedAt' },
      ...timestamps(),
    ],
    indexes: [
      'CREATE INDEX idx_animals_name ON animals (name)',
      'CREATE INDEX idx_animals_species ON animals (species)',
      'CREATE INDEX idx_animals_price ON animals (price)',
    ],
  })
  app.save(animals)

  // 6. customers
  const customers = new Collection({
    type: 'base',
    name: 'customers',
    listRule: managerOrAdmin,
    viewRule: managerOrAdmin + ' || userId = @request.auth.id',
    createRule: managerOrAdmin,
    updateRule: '@request.auth.role = "admin" || (@request.auth.role = "manager" && deletedAt = "") || (userId = @request.auth.id && @request.body.userId:changed = false && @request.body.deletedAt:changed = false)',
    deleteRule: adminOnly,
    fields: [
      { type: 'text', name: 'firstName', required: true, min: 2, max: 80, presentable: true },
      { type: 'text', name: 'lastName', required: true, min: 2, max: 80, presentable: true },
      { type: 'email', name: 'email', required: true },
      { type: 'text', name: 'phone', required: true, min: 7, max: 30 },
      { type: 'relation', name: 'userId', collectionId: users.id, maxSelect: 1, cascadeDelete: false },
      { type: 'date', name: 'deletedAt' },
      ...timestamps(),
    ],
    indexes: [
      'CREATE UNIQUE INDEX idx_customers_email ON customers (email)',
      'CREATE UNIQUE INDEX idx_customers_userId ON customers (userId) WHERE userId != \'\'',
      'CREATE INDEX idx_customers_lastName ON customers (lastName)',
    ],
  })
  app.save(customers)

  // 7. loyalty_cards
  const loyaltyCards = new Collection({
    type: 'base',
    name: 'loyalty_cards',
    listRule: managerOrAdmin + ' || customerId.userId = @request.auth.id',
    viewRule: managerOrAdmin + ' || customerId.userId = @request.auth.id',
    createRule: managerOrAdmin,
    updateRule: updateActiveOrAdmin,
    deleteRule: adminOnly,
    fields: [
      { type: 'relation', name: 'customerId', collectionId: customers.id, required: true, maxSelect: 1, cascadeDelete: true },
      { type: 'text', name: 'number', required: true, min: 4, max: 40, presentable: true },
      { type: 'select', name: 'level', required: true, maxSelect: 1, values: ['Bronze', 'Silver', 'Gold', 'Platinum'] },
      { type: 'number', name: 'points', onlyInt: true, min: 0 },
      { type: 'date', name: 'issuedAt', required: true },
      { type: 'date', name: 'deletedAt' },
      ...timestamps(),
    ],
    indexes: [
      'CREATE UNIQUE INDEX idx_loyalty_number ON loyalty_cards (number)',
      'CREATE UNIQUE INDEX idx_loyalty_customer ON loyalty_cards (customerId)',
    ],
  })
  app.save(loyaltyCards)

  // 8. orders
  const orders = new Collection({
    type: 'base',
    name: 'orders',
    listRule: managerOrAdmin + ' || customerId.userId = @request.auth.id',
    viewRule: managerOrAdmin + ' || customerId.userId = @request.auth.id',
    createRule: managerOrAdmin,
    updateRule: '@request.auth.role = "admin" || (@request.auth.role = "manager" && deletedAt = "")',
    deleteRule: adminOnly,
    fields: [
      { type: 'text', name: 'orderNumber', required: true, min: 4, max: 40, presentable: true },
      { type: 'relation', name: 'customerId', collectionId: customers.id, required: true, maxSelect: 1, cascadeDelete: false },
      { type: 'relation', name: 'createdById', collectionId: users.id, required: true, maxSelect: 1, cascadeDelete: false },
      { type: 'select', name: 'status', required: true, maxSelect: 1, values: ['new', 'paid', 'processing', 'completed', 'cancelled'] },
      { type: 'number', name: 'total', min: 0 },
      { type: 'text', name: 'notes', max: 1000 },
      { type: 'date', name: 'orderedAt', required: true },
      { type: 'date', name: 'deletedAt' },
      ...timestamps(),
    ],
    indexes: [
      'CREATE UNIQUE INDEX idx_orders_number ON orders (orderNumber)',
      'CREATE INDEX idx_orders_status ON orders (status)',
      'CREATE INDEX idx_orders_orderedAt ON orders (orderedAt)',
    ],
  })
  app.save(orders)

  // 9. order_items
  const orderItems = new Collection({
    type: 'base',
    name: 'order_items',
    listRule: managerOrAdmin + ' || orderId.customerId.userId = @request.auth.id',
    viewRule: managerOrAdmin + ' || orderId.customerId.userId = @request.auth.id',
    createRule: managerOrAdmin,
    updateRule: '(' + managerOrAdmin + ') && @request.body.orderId:changed = false',
    deleteRule: adminOnly,
    fields: [
      { type: 'relation', name: 'orderId', collectionId: orders.id, required: true, maxSelect: 1, cascadeDelete: true },
      { type: 'select', name: 'itemType', required: true, maxSelect: 1, values: ['product', 'animal'] },
      { type: 'relation', name: 'productId', collectionId: products.id, maxSelect: 1, cascadeDelete: false },
      { type: 'relation', name: 'animalId', collectionId: animals.id, maxSelect: 1, cascadeDelete: false },
      { type: 'number', name: 'quantity', required: true, onlyInt: true, min: 1, max: 9999 },
      { type: 'number', name: 'unitPrice', required: true, min: 0.01 },
      { type: 'number', name: 'lineTotal', required: true, min: 0.01 },
      ...timestamps(),
    ],
    indexes: [
      'CREATE INDEX idx_order_items_orderId ON order_items (orderId)',
    ],
  })
  app.save(orderItems)
}, (app) => {
  // Reverse order is important because of relations.
  const names = [
    'order_items',
    'orders',
    'loyalty_cards',
    'customers',
    'animals',
    'products',
    'suppliers',
    'categories',
  ]

  for (const name of names) {
    try {
      const collection = app.findCollectionByNameOrId(name)
      app.delete(collection)
    } catch (_) {
      // ignore missing collections during rollback
    }
  }

  // Restore the default PocketBase users collection configuration instead of deleting it.
  try {
    const users = app.findCollectionByNameOrId('users')
    const ownerRule = 'id = @request.auth.id'
    users.listRule = ownerRule
    users.viewRule = ownerRule
    users.createRule = ''
    users.updateRule = ownerRule
    users.deleteRule = ownerRule
    users.manageRule = null
    users.authRule = ''
    users.passwordAuth = { enabled: true, identityFields: ['email'] }

    const emailField = users.fields.getByName('email')
    if (emailField) emailField.required = true

    users.fields.removeByName('username')
    users.fields.removeByName('fullName')
    users.fields.removeByName('role')
    users.fields.removeByName('deletedAt')
    users.removeIndex('idx_users_username')
    app.save(users)
  } catch (_) {
    // ignore rollback cleanup errors
  }
})
