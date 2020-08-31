import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/product_provider.dart';

class EditProductsScreen extends StatefulWidget {
  static const String routeName = '/edit-products';
  @override
  _EditProductsScreenState createState() => _EditProductsScreenState();
}

class _EditProductsScreenState extends State<EditProductsScreen> {
  final _priceFocusNode = FocusNode();
  final _descFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProducts =
      Product(id: null, title: '', description: '', price: 0, imageUrl: '');
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProducts = Provider.of<Products>(context).findById(productId);
        _imageUrlController.text =
            _editedProducts.imageUrl; // Cannot use controller
      } // and initialValue together.
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    // TODO: implement initState
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _saveFormData() async {
    setState(() {
      _isLoading = true;
    });
    final isValid = _form.currentState.validate();
    if (isValid) {
      _form.currentState.save();
      if (_editedProducts.id == null) {
        try {
          await Provider.of<Products>(context, listen: false)
              .addProduct(_editedProducts);
        } catch (error) {
          showDialog<Null>(
              context: context,
              builder: (ctx) => AlertDialog(
                    title: Text('An error occured'),
                    content: Text('Something went wrong.'),
                    actions: [
                      FlatButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: Text('Ok'),
                      ),
                    ],
                  ));
        }
        // finally {
        //   setState(() {
        //     _isLoading = false;
        //   });
        //   Navigator.of(context).pop();
        // }
      } else {
        await Provider.of<Products>(context, listen: false)
            .updateProduct(_editedProducts.id, _editedProducts);
      }
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit/Add Products'),
      ),
      body: _isLoading
          ? CircularProgressIndicator()
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Title',
                          contentPadding: EdgeInsets.all(5)),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      initialValue: _editedProducts.title,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please Enter a Title';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProducts = Product(
                          id: _editedProducts.id,
                          title: value,
                          price: _editedProducts.price,
                          description: _editedProducts.description,
                          imageUrl: _editedProducts.imageUrl,
                          isFavorite: _editedProducts.isFavorite,
                        );
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Price',
                          contentPadding: EdgeInsets.all(5)),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_descFocusNode);
                      },
                      initialValue: _editedProducts.price.toString(),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter Price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid Price';
                        }
                        if (double.parse(value) < 0) {
                          return 'Price cannot be negative';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProducts = Product(
                          id: _editedProducts.id,
                          title: _editedProducts.title,
                          price: double.parse(value),
                          description: _editedProducts.description,
                          imageUrl: _editedProducts.imageUrl,
                          isFavorite: _editedProducts.isFavorite,
                        );
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Desciption',
                        contentPadding: EdgeInsets.all(5),
                      ),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.next,
                      focusNode: _descFocusNode,
                      initialValue: _editedProducts.description,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please Enter Description';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProducts = Product(
                          id: _editedProducts.id,
                          title: _editedProducts.title,
                          price: _editedProducts.price,
                          description: value,
                          imageUrl: _editedProducts.imageUrl,
                          isFavorite: _editedProducts.isFavorite,
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.grey),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Text('Enter a URL')
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Image URL',
                              contentPadding: EdgeInsets.all(5),
                            ),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            onFieldSubmitted: (_) {
                              _saveFormData();
                            },
                            initialValue: _editedProducts.imageUrl,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter a Image URL';
                              }
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return 'Please enter a valid URL';
                              }
                              if (!value.endsWith('.jpg') &&
                                  !value.endsWith('.jpeg') &&
                                  !value.endsWith('.png')) {
                                return 'Not a valid Image URL';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _editedProducts = Product(
                                id: _editedProducts.id,
                                title: _editedProducts.title,
                                price: _editedProducts.price,
                                description: _editedProducts.description,
                                imageUrl: value,
                                isFavorite: _editedProducts.isFavorite,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 80,
                      width: 130,
                      alignment: Alignment.center,
                      child: RaisedButton(
                        onPressed: _saveFormData,
                        child: Text(
                          'Submit',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
