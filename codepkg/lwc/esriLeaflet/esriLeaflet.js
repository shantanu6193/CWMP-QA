/**
 * Created by PREM on 12-10-2020.
 */

import { LightningElement, api } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import leaflet from '@salesforce/resourceUrl/Esri_Leaflet';


export default class EsriLeaflet extends LightningElement {
    map;
    @api latitude = "36.778259";
    @api longitude = "-119.417931";

    connectedCallback() {
        if(this.latitude == undefined || this.latitude == '') {
            this.latitude = "36.778259";
        }
         if(this.longitude == undefined || this.longitude == '') {
            this.longitude = "-119.417931";
        }
    }
    /*
    * Load esri leaflet js and style form static resource
    * Call initializeMap() method to render map
    */
    renderedCallback() {
        Promise.all([
            loadStyle(this, leaflet+ '/leaflet.css'),
            loadScript(this, leaflet+ '/leaflet.js'),
        ]).then(() => {
            loadScript(this, leaflet+ '/esri-leaflet.js' ).then(() => {
                    Promise.all([
                        loadStyle(this, leaflet+ '/esri-leaflet-geocoder.css'),
                        loadScript(this, leaflet+ '/esri-leaflet-geocoder.js'),
                        loadStyle(this, leaflet+ '/Custom_Leaflet_Style.css')
                    ]).then(() => {
                        console.log('success-------');
                        this.initializeMap();
                    }).catch(e => {
                        console.log('geocode exp--------',e);
                    });
                }).catch(e => {
               console.log('e-------',e);
            });
        }).catch(error => {
           console.log('script error----',error);
        });
    }

    /*
    * Added tile layer on map
    * Restricted search bound to california region
    * Search functionality to search address
    */
    initializeMap() {
        try{
            const container = this.template.querySelector('.map');
            var map = L.map(container).setView([Number(this.latitude), Number(this.longitude)], 10);

            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '&copy; <a href="https://osm.org/copyright">OpenStreetMap</a> contributors'
            }).addTo(map);

            /*-124.409591, 32.534156, -114.131211, 42.009518*/

            var corner1 = L.latLng(32.534156, -124.409591),
            corner2 = L.latLng(42.009518, -114.131211),
            bounds = L.latLngBounds(corner1, corner2);
            console.log('bounds----',bounds);
            var searchControl = L.esri.Geocoding.geosearch({
                position: 'topright',
                expanded: true,
                collapseAfterResult: false,
                useMapBounds: false,
                searchBounds: bounds
            }).addTo(map);

            var results = L.layerGroup().addTo(map);
            L.marker([Number(this.latitude), Number(this.longitude)]).addTo(map);
            searchControl.on('results', data => {
                results.clearLayers();
                for (var i = data.results.length - 1; i >= 0; i--) {
                    results.addLayer(L.marker(data.results[i].latlng));
                    let address = data.results;
                    console.log('data.results-----',data.results);
                    const addressSelectedEvent = new CustomEvent('selectedaddress', {
                        detail: { address },
                    });
                    this.dispatchEvent(addressSelectedEvent);
                }
            });
        }
        catch(e) {
            console.log(e);
        }
        /*try{
            console.log('in initialize');
            const container = this.template.querySelector('.map');
            console.log('l map---',L);
            this.map = L.map(container, {
                center: [36.778259, -119.417931],
                zoom: 10
            });
            this.layer = L.esri.basemapLayer('Streets').addTo(this.map);

            var arcgisOnline = L.esri.Geocoding.arcgisOnlineProvider();
            console.log('arcgisOnline----',arcgisOnline);
            let geoSearch = L.esri.Geocoding.geosearch({
                providers: [
                    arcgisOnline,
                    L.esri.Geocoding.featureLayerProvider({
                        url: 'https://services.arcgis.com/uCXeTVveQzP4IIcx/arcgis/rest/services/gisday/FeatureServer/0/',
                        label: 'GIS Day Events',
                        formatSuggestion: function (feature) {
                            try{
                                console.log('feature-----',feature);
                                return feature.properties.Name;
                            }
                            catch(e){
                                console.log(e);
                            }
                        }
                    })
                ],
                position:'topright'
            }).addTo(this.map);

            geoSearch.on('results', data => {
                try{
                    console.log('data-----',data);
                    let address = data.results;
                    console.log('data.results-----',data.results);
                    const addressSelectedEvent = new CustomEvent('selectedaddress', {
                        detail: { address },
                    });
                    // Fire the custom event
                    this.dispatchEvent(addressSelectedEvent);
                }
                catch(e) {
                    console.log(e);
                }
            });
        }
        catch(e){
            console.log(e);
        }*/
    }
}