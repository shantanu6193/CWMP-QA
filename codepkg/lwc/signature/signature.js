/* eslint-disable no-console */
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
import { LightningElement, api } from 'lwc';

//declaration of variables for calculations
let isDownFlag,
    isDotFlag = false,
    prevX = 0,
    currX = 0,
    prevY = 0,
    currY = 0;

let x = "#0000A0"; //blue color
let y = 1.5; //weight of line width and dot.       
let canvasElement, ctx; //storing canvas context
let dataURL, convertedDataURI; //holds image data
let drawing=false;
let pos = { x: 0, y: 0 };

export default class Signature extends LightningElement {
    @api signLabel='PLEASE SIGN HERE';
    //event listeners added for drawing the signature within shadow boundary
    constructor() {
        super();
        this.template.addEventListener('mousemove', this.handleMouseMove.bind(this));
        this.template.addEventListener('mousedown', this.handleMouseDown.bind(this));
        this.template.addEventListener('mouseup', this.handleMouseUp.bind(this));
        this.template.addEventListener('mouseout', this.handleMouseOut.bind(this));

        //Sravan - touch events for i-pad
        // this.template.addEventListener('touchstart', this.handleMouseDown.bind(this));
        // this.template.addEventListener('touchmove', this.handleMouseMove.bind(this));
        // this.template.addEventListener('touchend', this.handleMouseUp.bind(this));
        
        this.template.addEventListener("touchstart", function(e){ if (e.target.nodeName == 'CANVAS') { e.preventDefault(); } }, false);
        this.template.addEventListener("touchend", function(e){ if (e.target.nodeName == 'CANVAS') { e.preventDefault(); } }, false);
        this.template.addEventListener("touchmove", function(e){ if (e.target.nodeName == 'CANVAS') { e.preventDefault(); } }, false);

        this.template.addEventListener('touchstart', this.handleTouchStart.bind(this));
        this.template.addEventListener('touchmove', this.handleTouchMove.bind(this));
        this.template.addEventListener('touchend', this.handleTouchEnd.bind(this));
    }

    //retrieve canvase and context
    renderedCallback() {
        canvasElement = this.template.querySelector('.signCanvas');
        ctx = canvasElement.getContext("2d");
    }
 
    handleTouchStart(e){
        var touch = e.touches[0];
        var mouseEvent = new MouseEvent("mousedown", {
            clientX: touch.clientX,
            clientY: touch.clientY
        });       
        this.searchCoordinatesForEvent('down', mouseEvent);
    }

    handleTouchMove(e){

        drawing=true;       
        var touch = e.touches[0];
        var mouseEvent = new MouseEvent("mousemove", {
            clientX: touch.clientX,
            clientY: touch.clientY
        });
        this.searchCoordinatesForEvent('move', mouseEvent);
    }

    handleTouchEnd(e){
        drawing=false;
        var mouseEvent = new MouseEvent("mouseup", {});
        this.searchCoordinatesForEvent('up', mouseEvent);
    }

    //handler for mouse move operation
    handleMouseMove(event) {                
        this.searchCoordinatesForEvent('move', event);      
    }

    //handler for mouse down operation
    handleMouseDown(event) {
        this.searchCoordinatesForEvent('down', event);
    }

    //handler for mouse up operation
    handleMouseUp(event) {
        this.searchCoordinatesForEvent('up', event);
    }

    //handler for mouse out operation
    handleMouseOut(event) {
        this.searchCoordinatesForEvent('out', event);
    }

    @api
    getSignatureBlob() {
        ctx.globalCompositeOperation = "destination-over";
        ctx.fillStyle = "#FFF"; //white
        ctx.fillRect(1, 1, canvasElement.width, canvasElement.height);
        // blank canvas for validation
        let blank = this.template.querySelector('.blankCanvas')
        blank.width = canvasElement.width;
        blank.height = canvasElement.height;
        let ctx1 = blank.getContext("2d");
        ctx1.globalCompositeOperation = "destination-over";
        ctx1.fillStyle = "#FFF"; //white
        ctx1.fillRect(1, 1, canvasElement.width, canvasElement.height);
       
        if (canvasElement.toDataURL() == blank.toDataURL()) {
            return undefined;
        } 
        //c/signatureconvert to png image as dataURL
        dataURL = canvasElement.toDataURL("image/png");
        //convert that as base64 encoding
        convertedDataURI = dataURL.replace(/^data:image\/(png|jpg);base64,/, "");
        return convertedDataURI;
    }
    /*
        handler to perform save operation.
        save signature as attachment.
        after saving shows success or failure message as toast
    */
    handleSaveClick() {
        debugger;
        //set to draw behind current content
        ctx.globalCompositeOperation = "destination-over";
        ctx.fillStyle = "#FFF"; //white
        ctx.fillRect(1, 1, canvasElement.width, canvasElement.height);

        //c/signatureconvert to png image as dataURL
        dataURL = canvasElement.toDataURL("image/png");
        //convert that as base64 encoding
        convertedDataURI = dataURL.replace(/^data:image\/(png|jpg);base64,/, "");
        console.log(' test', convertedDataURI);
        //call Apex method imperatively and use promise for handling sucess & failure

    }

    //clear the signature from canvas
    handleClearClick() {
        ctx.clearRect(0, 0, canvasElement.width, canvasElement.height);
    }

    searchCoordinatesForEvent(requestedEvent, event) {
        event.preventDefault();
        if (requestedEvent === 'down') {
            this.setupCoordinate(event);
            isDownFlag = true;
            isDotFlag = true;
            if (isDotFlag) {
                this.drawDot();
                isDotFlag = false;
            }
        }
        if (requestedEvent === 'up' || requestedEvent === "out") {
            isDownFlag = false;
        }
        if (requestedEvent === 'move') {
            if (isDownFlag) {
                this.setupCoordinate(event);
                this.redraw();
            }
        }
    }

    //This method is primary called from mouse down & move to setup cordinates.
    setupCoordinate(eventParam) {
        //get size of an element and its position relative to the viewport 
        //using getBoundingClientRect which returns left, top, right, bottom, x, y, width, height.
        const clientRect = canvasElement.getBoundingClientRect();
        prevX = currX;
        prevY = currY;
        currX = eventParam.clientX - clientRect.left;
        currY = eventParam.clientY - clientRect.top;
    }

    //For every mouse move based on the coordinates line to redrawn
    redraw() {
        ctx.beginPath();
        ctx.moveTo(prevX, prevY);
        ctx.lineTo(currX, currY);
        ctx.strokeStyle = x; //sets the color, gradient and pattern of stroke
        ctx.lineWidth = y;
        ctx.closePath(); //create a path from current point to starting point
        ctx.stroke(); //draws the path
    }

    //this draws the dot
    drawDot() {
        ctx.beginPath();
        ctx.fillStyle = x; //blue color
        ctx.fillRect(currX, currY, y, y); //fill rectrangle with coordinates
        ctx.closePath();
    }
    @api refreshCanvas(event){
        canvasElement = this.template.querySelector('.signCanvas');
        ctx = canvasElement.getContext("2d");
        ctx.clearRect(0, 0, canvasElement.width, canvasElement.height);  
    }
    handleRestSign (event){
        this.refreshCanvas();
    }
}