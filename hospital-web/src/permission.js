import router from './router'
import store from './store'
import NProgress from 'nprogress'
import { getToken } from '@/utils/auth'
import {systemRouterMap, doctorRouterMap, patientRouterMap, radiologistRouterMap, constantRouterMap, publicRouterMap} from "./router"
import {getCookie} from "@/utils/cookies"

// 已加载的路由标记
let routesLoaded = false;

export function getPermission() {
  if (routesLoaded) return;

  const username = getCookie('username');
  let dynamicRoutes = [];

  if (username === 'admin') {
    dynamicRoutes = constantRouterMap.concat(systemRouterMap);
  } else if (username && username.startsWith('patient')) {
    dynamicRoutes = constantRouterMap.concat(patientRouterMap);
  } else if (username && username.startsWith('radiologist')) {
    dynamicRoutes = constantRouterMap.concat(radiologistRouterMap);
  } else {
    dynamicRoutes = constantRouterMap.concat(doctorRouterMap);
  }

  routesLoaded = true;
  router.options.routes = publicRouterMap.concat(dynamicRoutes);
  router.addRoutes(dynamicRoutes);
}

export function resetPermission() {
  routesLoaded = false;
  router.options.routes = publicRouterMap.slice();
}

// 路由守卫
router.beforeEach((to, from, next) => {
  NProgress.start();

  const token = getToken();
  const username = getCookie('username');

  const publicPaths = ['/', '/login', '/404'];
  const isPublicPage = publicPaths.includes(to.path) || to.name === 'publicIndex';

  if (isPublicPage) {
    next();
  } else if (!token && !username) {
    next('/');
  } else {
    if (!routesLoaded) {
      getPermission();
      next({ ...to, replace: true });
    } else {
      next();
    }
  }
});

router.afterEach(() => {
  NProgress.done();
});
