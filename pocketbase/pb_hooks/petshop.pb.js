// Extra PetShop backend validation for PocketBase.

function validateCatalogRelations(e, expectedKind) {
  const supplierId = e.record.getString('supplierId')
  const categoryIds = e.record.getStringSlice('categoryIds')

  if (!supplierId || categoryIds.length === 0) {
    throw new BadRequestError('Необходимо выбрать поставщика и хотя бы одну категорию.')
  }

  const supplier = e.app.findRecordById('suppliers', supplierId)
  const allowed = supplier.getStringSlice('allowedCategoryIds')

  for (const categoryId of categoryIds) {
    const category = e.app.findRecordById('categories', categoryId)
    const kind = category.getString('kind')

    if (kind !== expectedKind && kind !== 'both') {
      throw new BadRequestError('Выбрана категория неподходящего типа.')
    }

    if (allowed.indexOf(categoryId) === -1) {
      throw new BadRequestError('Поставщик не работает с одной из выбранных категорий.')
    }
  }

  e.next()
}

onRecordCreateRequest((e) => validateCatalogRelations(e, 'product'), 'products')
onRecordUpdateRequest((e) => validateCatalogRelations(e, 'product'), 'products')
onRecordCreateRequest((e) => validateCatalogRelations(e, 'animal'), 'animals')
onRecordUpdateRequest((e) => validateCatalogRelations(e, 'animal'), 'animals')

function validateOrderItem(e) {
  const type = e.record.getString('itemType')
  const productId = e.record.getString('productId')
  const animalId = e.record.getString('animalId')
  const quantity = e.record.getInt('quantity')
  const unitPrice = e.record.getFloat('unitPrice')

  if (type === 'product') {
    if (!productId || animalId) {
      throw new BadRequestError('Для позиции типа product должен быть выбран только товар.')
    }
  } else if (type === 'animal') {
    if (!animalId || productId) {
      throw new BadRequestError('Для позиции типа animal должно быть выбрано только животное.')
    }
    if (quantity !== 1) {
      throw new BadRequestError('Животное в заказе может иметь количество только 1.')
    }
  } else {
    throw new BadRequestError('Неизвестный тип позиции заказа.')
  }

  e.record.set('lineTotal', quantity * unitPrice)
  e.next()
}

function recalculateOrder(app, orderId) {
  if (!orderId) return

  let total = 0
  const items = app.findRecordsByFilter(
    'order_items',
    'orderId = {:orderId}',
    '',
    0,
    0,
    { orderId: orderId },
  )

  for (const item of items) {
    total += item.getFloat('lineTotal')
  }

  const order = app.findRecordById('orders', orderId)
  order.set('total', total)
  app.save(order)
}

onRecordCreateRequest((e) => {
  validateOrderItem(e)
  recalculateOrder(e.app, e.record.getString('orderId'))
}, 'order_items')

onRecordUpdateRequest((e) => {
  validateOrderItem(e)
  recalculateOrder(e.app, e.record.getString('orderId'))
}, 'order_items')

onRecordDeleteRequest((e) => {
  const orderId = e.record.getString('orderId')
  e.next()
  recalculateOrder(e.app, orderId)
}, 'order_items')
