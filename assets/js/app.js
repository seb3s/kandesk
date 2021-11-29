// We need to import the CSS so that esbuild will load it
import '../css/app.scss'

// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from 'phoenix'
//     import socket from './socket'
//
import 'phoenix_html'
import {Socket} from 'phoenix'
import {LiveSocket} from 'phoenix_live_view'

import $ from 'cash-dom'
import MicroModal from 'micromodal'
import Sortable from 'sortablejs'
import Swal from 'sweetalert2'
import tippy from 'tippy.js'
import gettext from 'gettext.js'
import croppie from 'croppie'

let webapp = (function (webapp) {

// --------------------------------------------------------------------------------------
// live_view hooks
// --------------------------------------------------------------------------------------
let phx_hooks = {};

// client hooks
// ------------
phx_hooks.show_modal = {
    mounted() { MicroModal.show(this.el.id, {
        disableScroll: true,
        onShow: () => { set_draggable(this,
            this.el.querySelector('.modal-card'),
            this.el.querySelector('.modal-card-head')); },
        onClose: () => { this.pushEvent('close_modal'); }
        })
    },
    beforeDestroy() { MicroModal.close(this.el.id) }
};

phx_hooks.slide_scroll = {
    mounted() { slide_scroll(this.el, document.getElementById(this.el.getAttribute('data-slider_id'))) }
};

phx_hooks.sortable_columns = {
    mounted() { Sortable.create(this.el, {
        group: this.el.getAttribute('data-sortable_group'),
        handle: '.column_header',
        onEnd: (Evt) => {
            let old_pos = Evt.oldIndex + 1,
                new_pos = Evt.newIndex + 1;
            if (old_pos != new_pos) {
                this.pushEvent('move_column', {
                    old_pos: old_pos,
                    new_pos: new_pos});
            }
        }})
    }
};

phx_hooks.sortable_tasks = {
    mounted() { Sortable.create(this.el, {
        group: this.el.getAttribute('data-sortable_group'),
        delay: 1, // let tippy time to get closed before dragging
        onEnd: (Evt) => {
            let task_id = parseInt(Evt.item.getAttribute('phx-value-id')),
                old_col = parseInt(Evt.from.dataset['column_id']),
                new_col = parseInt(Evt.to.dataset['column_id']),
                old_pos = Evt.oldIndex + 1,
                new_pos = Evt.newIndex + 1;
            if (!(old_pos == new_pos && old_col == new_col)) {
                this.pushEvent('move_task', {
                    task_id: task_id,
                    old_col: old_col,
                    new_col: new_col,
                    old_pos: old_pos,
                    new_pos: new_pos});
            }
        }})
    }
};

phx_hooks.sortable_tags = {
    mounted() { Sortable.create(this.el, {
        group: this.el.getAttribute('data-sortable_group'),
        handle: '.tag_handle',
        onEnd: (Evt) => {
            let old_pos = Evt.oldIndex + 1,
                new_pos = Evt.newIndex + 1;
            if (old_pos != new_pos) {
                this.pushEvent('move_tag', {
                    old_pos: old_pos,
                    new_pos: new_pos});
            }
        }})
    }
};

phx_hooks.tippy = {
    mounted() {
        let options = {delay: [300, 0]}
        if (this.el.getAttribute('data-tippy-content')) {
            tippy(this.el, options)
        } else {
            tippy(this.el.querySelectorAll('[data-tippy-content]'), options)
        }
    },
    updated() {
        // only update content for tippy that have hook & content on the same tag
        let content = this.el.getAttribute('data-tippy-content')
        if (content) {
            this.el._tippy.setContent(content)
        }
    }
}

phx_hooks.tippy_template = {
    mounted() {
        tippy(this.el, {
            content: document.getElementById(this.el.getAttribute('data-template')),
            allowHTML: true,
            interactive: true,
            interactiveBorder: 10,
            theme: 'light-border',
            placement: 'bottom-end',
            popperOptions: { strategy: 'fixed', },
            duration: [300, 1], // 1 to avoid getting popover in dragging image but get phx-click triggered
        })
    },
    updated() { this.el._tippy.setContent(
        document.getElementById(this.el.getAttribute('data-template')))
    }
}

webapp.close_tippy = function(item) {
    let tippyInstance = document.querySelector('[data-template="'+item.id+'"]')._tippy
    tippyInstance.hide()
}

phx_hooks.scroll_on_update = {
    updated() { this.el.scrollIntoView() }
}

function new_croppie(shape) {
    webapp.upload_avatar = new croppie(document.getElementById('upload_avatar'), {
        viewport: { width: 300, height: 300, type: shape},
        enableOrientation: true})
}

phx_hooks.upload_avatar = {
    mounted() {
        let delegate = this.el.getAttribute('data-hook-delegate'),
            shape = this.el.getAttribute('data-hook-shape'),
            that = this
        new_croppie(shape)
        $('#upload_crop').on('click', function(){
            webapp.upload_avatar.result({
                type: 'base64',
                circle: false,
                format: 'jpeg',
                quality: 0.95
            }).then(function (result) {
                webapp.upload_avatar.destroy()
                that.pushEvent('upload_avatar', { image : result, delegate: delegate })
            })
        })
    },
    updated() {
        let shape = this.el.getAttribute('data-hook-shape')
        new_croppie(shape)
    }
}

phx_hooks.utilities = {
    mounted() {
        // server hooks
        this.handleEvent('set_locale', ({locale}) => webapp.i18n.setLocale(locale))

        // push hook to be able to call push_event from js code (alpine, ...)
        webapp.push_hook = this
    }
}


// --------------------------------------------------------------------------------------
// debounce
// --------------------------------------------------------------------------------------
function debounce(func, wait, immediate) {
    var timeout;
    return function() {
        var context = this, args = arguments;
        var later = function() {
            timeout = null;
            if (!immediate) func.apply(context, args);
        };
        var callNow = immediate && !timeout;
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
        if (callNow) func.apply(context, args);
    };
};


// --------------------------------------------------------------------------------------
// image cropping
// --------------------------------------------------------------------------------------
webapp.croppie_read_file = function (input) {
    if (input.files && input.files[0]) {
        $('#panel_view_avatar').hide();
        $('#panel_crop_avatar').show();
        var reader = new FileReader();
        reader.onload = function (e) {
            webapp.upload_avatar.bind({ url: e.target.result }).then(function(){
                console.log('Cropper bind complete');
            });
        }
        reader.readAsDataURL(input.files[0]);
    }
};

webapp.croppie_cancel_load = function () {
    $('#panel_view_avatar').show();
    $('#panel_crop_avatar').hide();
    $('#upload_btn').val('');
};


// --------------------------------------------------------------------------------------
// draggable modals
// --------------------------------------------------------------------------------------
function set_draggable(caller, draggable, handler) {
    let x1 = 0, y1 = 0, x2 = 0, y2 = 0;
    // get viewport size to stop dragging too far
    let w = Math.max(document.documentElement.clientWidth, window.innerWidth || 0);
    let h = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);

    if (handler) { handler.addEventListener('mousedown', dragMouseDown); }

    function dragMouseDown(e) {
        e.preventDefault();
        if (e.which !== 1) return;
        // get the mouse cursor position at startup
        x2 = e.clientX;
        y2 = e.clientY;
        window.addEventListener('mousemove', elementDrag);
        window.addEventListener('mouseup', endDrag);
    }

    let push_modal_pos_fn = debounce(function(pos) { caller.pushEvent('set_modal_pos', {pos: pos}) }, 500);

    function elementDrag(e) {
        e.preventDefault();
        // prevent modal handler from going outside viewport
        if (e.clientX <= w && e.clientX >= 0 && e.clientY <= h && e.clientY >= 0) {
            // calculate the new cursor position
            x1 = x2 - e.clientX;
            y1 = y2 - e.clientY;
            x2 = e.clientX;
            y2 = e.clientY;
            // set the element's new position
            draggable.style.left = (draggable.offsetLeft - x1) + 'px';
            draggable.style.top = (draggable.offsetTop - y1) + 'px';
            draggable.style.right = 'unset';
            draggable.style.bottom = 'unset';
            draggable.style.position = 'fixed';
            // debounce update of liveview state to keep modal pos on subsequent liveview updates
            push_modal_pos_fn(draggable.style.cssText);
        }
    }

    function endDrag() {
        window.removeEventListener('mousemove', elementDrag);
        window.removeEventListener('mouseup', endDrag);
    }
};


// --------------------------------------------------------------------------------------
// board scrolling
// --------------------------------------------------------------------------------------
function slide_scroll(handler, slider) {
    let startX;
    let scrollLeft;

    handler.addEventListener('mousedown', (e) => {
        if (e.which !== 1) return;
        if (e.target !== e.currentTarget) return;
        startX = e.pageX - slider.offsetLeft;
        scrollLeft = slider.scrollLeft;
        window.addEventListener('mousemove', elementDrag);
        window.addEventListener('mouseup', endDrag);
    })

    function elementDrag(e) {
        e.preventDefault();
        const x = e.pageX - slider.offsetLeft;
        const walk = (x - startX);
        slider.scrollLeft = scrollLeft - walk;
    }

    function endDrag() {
        window.removeEventListener('mousemove', elementDrag);
        window.removeEventListener('mouseup', endDrag);
    }
};


// --------------------------------------------------------------------------------------
// live_view live_socket
// --------------------------------------------------------------------------------------
let csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
webapp.live_socket = new LiveSocket('/live', Socket, {
    params: {_csrf_token: csrfToken},
    hooks: phx_hooks});
webapp.live_socket.connect();


// --------------------------------------------------------------------------------------
// overrides default data confirmation to use swal
// --------------------------------------------------------------------------------------
function extractPhxValue(el, meta) {
    let prefix = 'phx-value-';
    for (let i = 0; i < el.attributes.length; i++) {
      let name = el.attributes[i].name;
      if(name.startsWith(prefix)){ meta[name.replace(prefix, '')] = el.getAttribute(name) };
    }
    return meta;
};

document.body.addEventListener('phoenix.link.click', function (e) {
    e.stopPropagation();
    let message = e.target.getAttribute('data-confirm');
    if(!message) { return true; };
    e.preventDefault();

    let el = e.target,
        event = el.getAttribute('phx-click'),
        meta = extractPhxValue(el, {});

    Swal.fire({
        title: message,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonText: webapp.i18n.gettext('Yes'),
        cancelButtonText: webapp.i18n.gettext('Cancel')
    }).then((result) => {
        if (result.value) {
            webapp.push_hook.pushEvent(event, meta);
        }
    })
}, false);


// --------------------------------------------------------------------------------------
// js translations
// --------------------------------------------------------------------------------------
webapp.i18n = new gettext();
webapp.i18n.setMessages('messages', 'fr', {
  'Yes': 'Oui',
  'Cancel': 'Annuler'
}, 'nplurals=2; plural=n>1;');


return webapp;

}(webapp || {}));

window.webapp = webapp;
window.$ = $;
