var path = require('path');
var webpack = require('webpack');

console.log(__dirname);

module.exports = {
  entry: [
    path.resolve('src/Main'),
  ],
  output: {
    publicPath: '/',
    filename: 'hexgrid.js',
  },
  devtool: 'source-map',
  resolve: {
    modules: [path.resolve('.'), path.resolve('node_modules'), path.resolve('src')],
    extensions: [".js", ".coffee"],
  },
  module: {
    rules: [
      {
	test: /\.coffee$/,
	use: [ 
          {
            loader: 'coffee-loader',
            options: { sourceMap: true },
          },
        ],
      },
    ],
  },
};


