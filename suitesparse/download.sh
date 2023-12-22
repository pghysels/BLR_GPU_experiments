#!/bin/bash

wget https://suitesparse-collection-website.herokuapp.com/MM/Janna/Serena.tar.gz
wget https://suitesparse-collection-website.herokuapp.com/MM/Janna/Flan_1565.tar.gz
wget https://suitesparse-collection-website.herokuapp.com/MM/Janna/Geo_1438.tar.gz
wget https://suitesparse-collection-website.herokuapp.com/MM/Janna/Hook_1498.tar.gz
wget https://suitesparse-collection-website.herokuapp.com/MM/Janna/StocF-1465.tar.gz
wget https://suitesparse-collection-website.herokuapp.com/MM/Janna/Cube_Coup_dt0.tar.gz
wget https://suitesparse-collection-website.herokuapp.com/MM/Janna/Cube_Coup_dt6.tar.gz
wget https://suitesparse-collection-website.herokuapp.com/MM/Janna/Long_Coup_dt0.tar.gz
wget https://suitesparse-collection-website.herokuapp.com/MM/Janna/Long_Coup_dt6.tar.gz
wget https://suitesparse-collection-website.herokuapp.com/MM/Janna/Transport.tar.gz
wget https://suitesparse-collection-website.herokuapp.com/MM/Janna/ML_Geer.tar.gz
wget https://suitesparse-collection-website.herokuapp.com/MM/Janna/Bump_2911.tar.gz
wget https://suitesparse-collection-website.herokuapp.com/MM/Janna/Queen_4147.tar.gz
for f in *; do
    tar -xvzf $f
    mv */*.mtx .
done

